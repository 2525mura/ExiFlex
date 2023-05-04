#include <esp_sleep.h>
#include "src/Controllers/FrontPanelController.h"
#include "src/Infrastructures/EspBleService.h"

ESP_EVENT_DECLARE_BASE(APP_EVENT_BASE);

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
      esp_event_isr_post_to(frontPanelCtl->loopHandle, APP_EVENT_BASE, EVENT_SHUTTER, NULL, 0, NULL);
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
    esp_event_isr_post_to(frontPanelCtl->loopHandle, APP_EVENT_BASE, EVENT_LUX, NULL, 0, NULL);
    measureLuxCounter = 0;
  } else {
    measureLuxCounter++;
  }

  // generate EVENT_RGB
  if (measureRGBCounter > 200) {
    esp_event_isr_post_to(frontPanelCtl->loopHandle, APP_EVENT_BASE, EVENT_RGB, NULL, 0, NULL);
    measureRGBCounter = 0;
  } else {
    measureRGBCounter++;
  }

}

void espBleServiceStart(void *pvParameters) {
  // この関数はreturnさせてはいけない(resetしてしまう)
  iEspBleService->run(pvParameters);
}

void setup() {
  // init BLE service
  iEspBleService = new EspBleService();
  iEspBleService->setup();
  frontPanelCtl = new FrontPanelController(iEspBleService);
  iEspBleService->startService();
  xTaskCreateUniversal(espBleServiceStart, "BleTask", 8192, NULL, 10, NULL, CONFIG_ARDUINO_RUNNING_CORE);

  frontPanelCtl->init();
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
  frontPanelCtl->shutdown();
  // deep sleep
  esp_deep_sleep_start();
}

void loop() {
    delay(1000);
}
