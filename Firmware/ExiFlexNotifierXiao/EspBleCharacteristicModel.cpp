//
//  EspBleCharacteristicModel.cpp
//  Exiflex EspBleCharacteristicModel
//
//  Created by 村井慎太郎 on 2023/02/12.
//

#include "EspBleCharacteristicModel.h"

EspBleCharacteristicModel::EspBleCharacteristicModel(BLECharacteristic* pCharacteristic, String alias) {
    this->pCharacteristic = pCharacteristic;
    this->alias = alias;
}

BLECharacteristic* EspBleCharacteristicModel::getCharacteristic() {
    return pCharacteristic;
}

String EspBleCharacteristicModel::getAlias() {
    return alias;
}
