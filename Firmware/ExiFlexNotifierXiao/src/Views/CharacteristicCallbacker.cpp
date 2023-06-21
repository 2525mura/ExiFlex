#include "CharacteristicCallbacker.h"

CharacteristicCallbacker::CharacteristicCallbacker() {
}

void CharacteristicCallbacker::setFunc(const CharacteristicCallbackFunc& callback) {
    onWriteFunc = callback;
}

void CharacteristicCallbacker::onWrite(BLECharacteristic *pCharacteristic) {
    // Call function object
    if(onWriteFunc) {
        onWriteFunc(pCharacteristic->getValue());
    }
}
