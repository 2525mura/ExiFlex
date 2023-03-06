#include <esp_sleep.h>
#include "src/Controllers/FrontPanelController.h"
#include "src/Infrastructures/EspBleService.h"

ESP_EVENT_DEFINE_BASE(APP_EVENT_BASE);
typedef enum {
  EVENT_SHUTTER,
  EVENT_LUX,
  EVENT_RGB
} EventID;

esp_event_loop_handle_t loop_handle;
// BLE Service
IEspBleService* iEspBleService = NULL;
// Front panel controller
FrontPanelController* frontPanelCtl = NULL;
// main timer (1ms interval)
hw_timer_t * mainTimer = NULL;
// prevent chattering
bool preventChatteringSection = false;
unsigned int preventChatteringCounter = 0;
// measure Lux interval counter
unsigned int measureLuxCounter = 0;
// measure RGB interval counter
unsigned int measureRGBCounter = 0;

void IRAM_ATTR onShutter() {
  // Use only ISR-safe functions
  if (!preventChatteringSection) {
    preventChatteringSection = true;
    if(iEspBleService->deviceConnected) {
      esp_event_isr_post_to(loop_handle, APP_EVENT_BASE, EVENT_SHUTTER, NULL, 0, NULL);
    }
  }
}

void IRAM_ATTR onMainTimer() {
  // チャタリング防止用フラグ管理
  if (!preventChatteringSection) {
    // reset
    preventChatteringCounter = 0;
  } else if (preventChatteringSection && preventChatteringCounter<200) {
    // チャタリング排他中
    // カウントアップ
    preventChatteringCounter++;
  } else {
    // reset
    preventChatteringSection = false;
    preventChatteringCounter = 0;
  }

  // generate EVENT_LUX
  if (measureLuxCounter > 100) {
    esp_event_isr_post_to(loop_handle, APP_EVENT_BASE, EVENT_LUX, NULL, 0, NULL);
    measureLuxCounter = 0;
  } else {
    measureLuxCounter++;
  }

  // generate EVENT_RGB
  if (measureRGBCounter > 200) {
    esp_event_isr_post_to(loop_handle, APP_EVENT_BASE, EVENT_RGB, NULL, 0, NULL);
    measureRGBCounter = 0;
  } else {
    measureRGBCounter++;
  }

}

void espBleServiceStart(void *pvParameters) {
  // この関数はreturnさせてはいけない(resetしてしまう)
  iEspBleService->run(pvParameters);
}

// Main event handler
void run_on_event(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {
  switch (id) {
  case EVENT_SHUTTER:
    frontPanelCtl->onShutterEvent();
    break;
  case EVENT_LUX:
    frontPanelCtl->onMeasureLuxEvent();
    break;
  case EVENT_RGB:
    frontPanelCtl->onMeasureRGBEvent();
    break;
  default:
    break;
  }
}

void setup() {
  // init BLE service
  iEspBleService = new EspBleService();
  iEspBleService->setup();
  frontPanelCtl = new FrontPanelController(iEspBleService);
  iEspBleService->startService();
  xTaskCreateUniversal(espBleServiceStart, "BleTask", 8192, NULL, 10, NULL, CONFIG_ARDUINO_RUNNING_CORE);

  // Main event loop init
  esp_event_loop_args_t loop_args = {
      .queue_size = 32,
      .task_name = "AppTask",
      .task_priority = uxTaskPriorityGet(NULL) + 1,
      .task_stack_size = 8192,
      .task_core_id = CONFIG_ARDUINO_RUNNING_CORE
  };
  esp_event_loop_create(&loop_args, &loop_handle);
  esp_event_handler_register_with(loop_handle, APP_EVENT_BASE, EVENT_SHUTTER, run_on_event, NULL);
  esp_event_handler_register_with(loop_handle, APP_EVENT_BASE, EVENT_LUX, run_on_event, NULL);
  esp_event_handler_register_with(loop_handle, APP_EVENT_BASE, EVENT_RGB, run_on_event, NULL);

  // ペリフェラル初期化
  Serial.begin(115200);

  // メインタイマー初期化:1msごとにハンドラ実行
  mainTimer = timerBegin(0, 80, true);
  timerAttachInterrupt(mainTimer, &onMainTimer, true);
  timerAlarmWrite(mainTimer, 1000, true);
  timerAlarmEnable(mainTimer);

  // シャッター割り込みを登録
  pinMode(D6, INPUT_PULLUP);
  attachInterrupt(D6, onShutter, FALLING);

  // DeepSleep復帰GPIOピン設定
  esp_deep_sleep_enable_gpio_wakeup(BIT(D1), ESP_GPIO_WAKEUP_GPIO_LOW);

  // main task(just waiting)
  delay(300000);
  // shutdown
  frontPanelCtl->ledOff(1);
  frontPanelCtl->ledOff(2);
  frontPanelCtl->ledOff(3);
  esp_event_handler_unregister_with(loop_handle, APP_EVENT_BASE, EVENT_SHUTTER, run_on_event);
  esp_event_handler_unregister_with(loop_handle, APP_EVENT_BASE, EVENT_LUX, run_on_event);
  esp_event_handler_unregister_with(loop_handle, APP_EVENT_BASE, EVENT_RGB, run_on_event);
  esp_event_loop_delete(loop_handle);
  // deep sleep
  esp_deep_sleep_start();
}

void loop() {
    delay(1000);
}
