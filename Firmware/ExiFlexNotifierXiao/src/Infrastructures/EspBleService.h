//
//  EspBleService.h
//  Exiflex ESP BLE Service
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "Arduino.h"
#include "EspBleCharacteristicModel.h"
#include "EspBlePeripheralDelegate.h"
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <map>

#ifndef __ESP_BLE_SERVICE_H__
#define __ESP_BLE_SERVICE_H__

class IEspBleService {
  public:
    // Please call in the following order
    virtual void Setup() = 0;
    virtual void AddCharacteristicUuid(String characteristicUuid, String alias) = 0;
    virtual void StartService() = 0;
    virtual void LoopTask(void *pvParameters) = 0;
    virtual void SendMessage(String characteristicUuid, String message) = 0;
    virtual void setDelegate(EspBlePeripheralDelegate* delegate) = 0;
    bool deviceConnected = false;
};

class EspBleService: public IEspBleService, BLEServerCallbacks, BLECharacteristicCallbacks {
  public:
    EspBleService();
    void Setup();
    void AddCharacteristicUuid(String characteristicUuid, String alias);
    void StartService();
    void LoopTask(void *pvParameters);
    void SendMessage(String characteristicUuid, String message);
    void setDelegate(EspBlePeripheralDelegate* delegate);

  private:
    void onConnect(BLEServer* pServer);
    void onDisconnect(BLEServer* pServer);
    void onWrite(BLECharacteristic *pCharacteristic);
    BLEServer* pServer = NULL;
    BLEService* pService = NULL;
    bool oldDeviceConnected = false;
    std::map<std::string, EspBleCharacteristicModel*> bleCharacteristicMap;
    EspBlePeripheralDelegate* blePeripheraldelegate = NULL;

};

#endif __ESP_BLE_SERVICE_H__
