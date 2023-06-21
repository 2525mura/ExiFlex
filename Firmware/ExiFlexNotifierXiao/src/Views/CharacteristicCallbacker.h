#include <functional>
#include <BLECharacteristic.h>

#ifndef __CHARACTERISTIC_CALLBACKER_H__
#define __CHARACTERISTIC_CALLBACKER_H__

using CharacteristicCallbackFunc = std::function<void(std::string)>;
class CharacteristicCallbacker : public BLECharacteristicCallbacks {
    public:
        CharacteristicCallbacker();
        void setFunc(const CharacteristicCallbackFunc& callback);
    private:
        void onWrite(BLECharacteristic* pCharacteristic) override;
        CharacteristicCallbackFunc onWriteFunc;
};

#endif __CHARACTERISTIC_CALLBACKER_H__
