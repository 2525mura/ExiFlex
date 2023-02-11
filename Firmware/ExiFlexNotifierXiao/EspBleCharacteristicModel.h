//
//  EspBleCharacteristicModel.h
//  Exiflex EspBleCharacteristicModel
//
//  Created by 村井慎太郎 on 2023/02/12.
//

#include "Arduino.h"
#include <BLEDevice.h>

class EspBleCharacteristicModel {
    public:
        EspBleCharacteristicModel(BLECharacteristic* pCharacteristic, String alias);
        BLECharacteristic* getCharacteristic();
        String getAlias();
    private:
        BLECharacteristic* pCharacteristic;
        String alias;
};
