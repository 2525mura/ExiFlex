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
        virtual void setup() = 0;
        virtual void addCharacteristicUuid(String characteristicUuid, String alias) = 0;
        virtual void startService() = 0;
        virtual void run(void *pvParameters) = 0;
        virtual void sendMessage(String characteristicUuid, String message) = 0;
        virtual void setDelegate(EspBlePeripheralDelegate* delegate) = 0;
        bool deviceConnected = false;
};

class EspBleService: public IEspBleService, BLEServerCallbacks, BLECharacteristicCallbacks {
    public:
        EspBleService();
        void setup();
        void addCharacteristicUuid(String characteristicUuid, String alias);
        void startService();
        void run(void *pvParameters);
        void sendMessage(String characteristicUuid, String message);
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
