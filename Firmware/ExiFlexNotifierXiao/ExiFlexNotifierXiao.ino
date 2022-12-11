/*
    Video: https://www.youtube.com/watch?v=oCMOYS71NIU
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
    Ported to Arduino ESP32 by Evandro Copercini
    updated by chegewara

   Create a BLE server that, once we receive a connection, will send periodic notifications.
   The service advertises itself as: 4fafc201-1fb5-459e-8fcc-c5c9c331914b
   And has a characteristic of: beb5483e-36e1-4688-b7f5-ea07361b26a8

   The design of creating the BLE server is:
   1. Create a BLE Server
   2. Create a BLE Service
   3. Create a BLE Characteristic on the Service
   4. Create a BLE Descriptor on the characteristic
   5. Start the service.
   6. Start advertising.

   A connect hander associated with the server starts a background task that performs notification
   every couple of seconds.
*/
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <esp_sleep.h>
#include "AE_TSL2572.h"
#include "MU_S11059.h"
#include "PCF8574.h"
  
// BLEドライバー
BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristicShutter = NULL;
BLECharacteristic* pCharacteristicLux = NULL;
BLECharacteristic* pCharacteristicRGB = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;
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
// IOエキスパンダー
PCF8574 expander(0x20);

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_LUX_UUID "16cf81e3-0212-58b9-0380-0dbc6b54c51d"
#define CHARACTERISTIC_RGB_UUID "67f46ec5-3d54-54c2-ae2d-fb318a4973b0"


class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

void notifyShutter() {
  if (deviceConnected) {
    String out = "SHUTTER";
    Serial.println(out);
    pCharacteristicShutter->setValue(out.c_str());
    pCharacteristicShutter->notify();
  }
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
    Serial.println(out);
    pCharacteristicLux->setValue(out.c_str());
    pCharacteristicLux->notify();
    //自動ゲイン調整
    // TSL2572.SetGainAuto();
}

void mesureColor() {
    //TSL2572.GetLux16()で照度を取得
    ColorLux colorLux = S11059.GetLux();
    String out = "R:" + String(colorLux.lux_r, DEC) + " G:" + String(colorLux.lux_g, DEC) + " B:" + String(colorLux.lux_b, DEC) + " IR:" + String(colorLux.lux_ir, DEC);
    Serial.println(out);
    pCharacteristicRGB->setValue(out.c_str());
    pCharacteristicRGB->notify();

    //デバッグ用
    Serial.println(String(getRotarySwValue(), DEC)+ " " +String(analogRead(A0), DEC));
}


byte getRotarySwValue() {
  byte value = expander.read8() & 0x0F;
  return value;
}

void setup() {

  int f_value = analogRead(A0);
  // Expanderの出力をAll HIにする
  expander.begin();
  expander.write8(0xFF);
  // LED点灯
  expander.write(4, LOW);
  expander.write(5, LOW);
  expander.write(6, LOW);

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
  
  // Create the BLE Device
  BLEDevice::init("ESP32");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic for shutter
  pCharacteristicShutter = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
  // Create a BLE Descriptor
  pCharacteristicShutter->addDescriptor(new BLE2902());

  // Create a BLE Characteristic for lux sensor
  pCharacteristicLux = pService->createCharacteristic(
                      CHARACTERISTIC_LUX_UUID,
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristicLux->addDescriptor(new BLE2902());

  // Create a BLE Characteristic for XYZ sensor
  pCharacteristicRGB = pService->createCharacteristic(
                      CHARACTERISTIC_RGB_UUID,
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristicRGB->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");

}

void loop() {

  if(startUpCounter < 30000) {

    // notify changed value
    if (deviceConnected) {
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
      delay(10); // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
    }
    // シャッター通知
    if(notifyShutterFlg) {
      notifyShutter();
      notifyShutterFlg = false;
    }
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }

  } else {
    // LED消灯
    expander.write(4, HIGH);
    expander.write(5, HIGH);
    expander.write(6, HIGH);
    // deep sleep
    esp_deep_sleep_start();
  }
}