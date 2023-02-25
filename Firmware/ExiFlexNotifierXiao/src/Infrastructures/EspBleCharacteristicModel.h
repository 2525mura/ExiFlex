//
//  EspBleCharacteristicModel.h
//  Exiflex EspBleCharacteristicModel
//
//  Created by 村井慎太郎 on 2023/02/12.
//

#include "Arduino.h"
#include <BLEDevice.h>

#ifndef __ESP_BLE_CHARACTERISTIC_MODEL_H__
#define __ESP_BLE_CHARACTERISTIC_MODEL_H__

class EspBleCharacteristicModel {
    public:
        EspBleCharacteristicModel(BLECharacteristic* pCharacteristic, String alias);
        BLECharacteristic* getCharacteristic();
        String getAlias();
    private:
        BLECharacteristic* pCharacteristic;
        String alias;
};

#endif __ESP_BLE_CHARACTERISTIC_MODEL_H__
