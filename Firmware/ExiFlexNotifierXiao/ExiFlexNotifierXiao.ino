#include <esp_sleep.h>
#include "src/Controllers/FrontPanelController.h"
#include "src/Infrastructures/EspBleService.h"

#define CHARACTERISTIC_EVENT_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// BLE Service
IEspBleService* iEspBleService = NULL;
// Front panel controller
FrontPanelController* frontPanelCtl = NULL;
// メインタイマー（1ms周期）
hw_timer_t * mainTimer = NULL;
// チャタリング防止制御用
bool antiChatteringMutex = false;
unsigned int antiChatteringCounter = 0;
// シャッター通知フラグ
bool notifyShutterFlg = false;
// 起動時間タイマー
unsigned int startUpCounter = 0;

void notifyShutter() {
  String out = "SHUTTER";
  iEspBleService->SendMessage(CHARACTERISTIC_EVENT_UUID, out);
}

void IRAM_ATTR onShutter() {
  // 割り込み処理に重い処理を入れないこと
  if (!antiChatteringMutex) {
    // 排他フラグを有効にする
    // 一定時間後にメインタイマー処理でfalseに落とされる
    antiChatteringMutex = true;
    notifyShutterFlg = true;
  }
}

void IRAM_ATTR onMainTimer() {
  // チャタリング防止用フラグ管理
  if (!antiChatteringMutex) {
    // カウンターリセット
    antiChatteringCounter = 0;
  } else if (antiChatteringMutex && antiChatteringCounter<200) {
    // チャタリング排他中
    // カウントアップ
    antiChatteringCounter++;
  } else {
    antiChatteringMutex = false;
    antiChatteringCounter = 0;
  }

  // 起動時間タイマー
  startUpCounter++;
}

void espBleServiceStart(void *pvParameters) {
  // この関数はreturnさせてはいけない(resetしてしまう)
  iEspBleService->LoopTask(pvParameters);
}

void frontPanelCtlStart(void *pvParameters) {
  // この関数はreturnさせてはいけない(resetしてしまう)
  frontPanelCtl->LoopTask(pvParameters);
}

void setup() {

  // BLEサービス初期化
  iEspBleService = new EspBleService();
  iEspBleService->Setup();
  iEspBleService->AddCharacteristicUuid(CHARACTERISTIC_EVENT_UUID, "event");
  frontPanelCtl = new FrontPanelController(iEspBleService);
  iEspBleService->StartService();
  xTaskCreateUniversal(espBleServiceStart, "BleTask", 8192, NULL, 10, NULL, CONFIG_ARDUINO_RUNNING_CORE);
  xTaskCreateUniversal(frontPanelCtlStart, "FrontPanelTask", 8192, NULL, 10, NULL, CONFIG_ARDUINO_RUNNING_CORE);

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

}

void loop() {

  if(startUpCounter < 300000) {

      // notify changed value
    if(iEspBleService->deviceConnected) {
      // シャッター通知
      if(notifyShutterFlg) {
        notifyShutter();
        notifyShutterFlg = false;
      }
      delay(10);
    }

  } else {
    // LED消灯
    frontPanelCtl->LedOff(1);
    frontPanelCtl->LedOff(2);
    frontPanelCtl->LedOff(3);
    // deep sleep
    esp_deep_sleep_start();
  }
}
