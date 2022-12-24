//
//  EspBleService.h
//  Exiflex ESP BLE Service
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "Arduino.h"
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

class EspBleService {
  public:
    EspBleService();
    void Setup();
    void LoopTask(void *pvParameters);

    // BLE Handle
    BLEServer* pServer = NULL;
    BLECharacteristic* pCharacteristicShutter = NULL;
    BLECharacteristic* pCharacteristicLux = NULL;
    BLECharacteristic* pCharacteristicRGB = NULL;
    bool deviceConnected = false;
    bool oldDeviceConnected = false;

  private:

};

class MyServerCallbacks: public BLEServerCallbacks {
  public:
    EspBleService* pService = NULL;
    MyServerCallbacks(EspBleService* pService) {
      this->pService = pService;
    }

    void onConnect(BLEServer* pServer) {
      pService->deviceConnected = true;
    }

    void onDisconnect(BLEServer* pServer) {
      pService->deviceConnected = false;
    }
};
