#include "EspBleService.h"
#include "FrontPanelController.h"
#include <esp_sleep.h>
#include "AE_TSL2572.h"
#include "MU_S11059.h"

#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_LUX_UUID "16cf81e3-0212-58b9-0380-0dbc6b54c51d"
#define CHARACTERISTIC_RGB_UUID "67f46ec5-3d54-54c2-ae2d-fb318a4973b0"

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
// Luxセンサー
AE_TSL2572 TSL2572;
bool luxSensorConnected = false;
unsigned int luxWaitCounter = 0;
// Colorセンサー
MU_S11059 S11059;
unsigned int colorWaitCounter = 0;
// 起動時間タイマー
unsigned int startUpCounter = 0;

void notifyShutter() {
  String out = "SHUTTER";
  Serial.println(out);
  iEspBleService->SendMessage(CHARACTERISTIC_UUID, out);
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

bool initLuxSensor() {
  //ゲイン　0～ 5 (x0.167 , x1.0 , x1.33 , x8 , x16 , x120)
  byte gain_step = 1;
  
  //積分時間のカウンタ(0xFFから減るごとに+2.73ms)
  //0xFF：  1サイクル(約 2.73ms)
  //0xDB： 37サイクル(約  101ms)
  //0xC0： 64サイクル(約  175ms)
  //0x00：256サイクル(約  699ms)
  byte atime_cnt = 0xC0;
  
  if (TSL2572.CheckID()) {
    //ゲインを設定
    TSL2572.SetGain(gain_step);
    //積分時間を設定
    TSL2572.SetIntegralTime(atime_cnt);

    //計測開始
    TSL2572.Reset();
    delay(100);
  }
  else {
    Serial.println("Failed. Check connection!!");
    return false;
  }
  return true;
}

void mesureLux() {
    //TSL2572.GetLux16()で照度を取得
    uint16_t lux = TSL2572.GetLux16();
    String out = "LUX:" + String(lux, DEC);
    iEspBleService->SendMessage(CHARACTERISTIC_LUX_UUID, out);
    //自動ゲイン調整
    // TSL2572.SetGainAuto();
}

void mesureColor() {
    //TSL2572.GetLux16()で照度を取得
    ColorLux colorLux = S11059.GetLux();
    String out = "R:" + String(colorLux.lux_r, DEC) + " G:" + String(colorLux.lux_g, DEC) + " B:" + String(colorLux.lux_b, DEC) + " IR:" + String(colorLux.lux_ir, DEC);
    iEspBleService->SendMessage(CHARACTERISTIC_RGB_UUID, out);

    //デバッグ用
    //Serial.println(String(getRotarySwValue(), DEC)+ " " +String(analogRead(A0), DEC));
}

void espBleServiceStart(void *pvParameters) {
  // この関数はreturnさせてはいけない(resetしてしまう)
  iEspBleService->LoopTask(pvParameters);
}

void setup() {

  // BLEサービス初期化
  iEspBleService = new EspBleService();
  iEspBleService->Setup();
  iEspBleService->AddCharacteristicUuid(CHARACTERISTIC_UUID);
  iEspBleService->AddCharacteristicUuid(CHARACTERISTIC_LUX_UUID);
  iEspBleService->AddCharacteristicUuid(CHARACTERISTIC_RGB_UUID);
  frontPanelCtl = new FrontPanelController(iEspBleService);
  iEspBleService->StartService();
  xTaskCreateUniversal(espBleServiceStart, "BleTask", 8192, NULL, 10, NULL, CONFIG_ARDUINO_RUNNING_CORE);

  // LED点灯
  frontPanelCtl->LedOn(1);
  frontPanelCtl->LedOn(2);
  frontPanelCtl->LedOn(3);

  // ペリフェラル初期化
  Serial.begin(115200);
  Wire.begin(SDA, SCL);

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

  // Luxセンサー初期化
  luxSensorConnected = initLuxSensor();
  // Colorセンサー初期化
  S11059.SetIntegralTime(MU_S11059::S11059_INTTIME_175, 285);

}

void loop() {

  if(startUpCounter < 30000) {

      // notify changed value
    if(iEspBleService->deviceConnected) {
      // Luxセンサー送信処理
      if (luxWaitCounter < 20) {
        luxWaitCounter++;
      } else {
        luxWaitCounter = 0;
        if (luxSensorConnected) {
          mesureLux();
        }
      }
      // Colorセンサー送信処理
      if (colorWaitCounter < 20) {
        colorWaitCounter++;
      } else {
        colorWaitCounter = 0;
          mesureColor();
      }
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
