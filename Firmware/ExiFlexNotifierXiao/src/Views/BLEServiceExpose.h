/**
 * This code was generated by BlueJinja
 *
 */

#include <memory>
#include <BLEDevice.h>
#include <BLEService.h>
#include <BLECharacteristic.h>
#include <BLE2902.h>
#include "CharacteristicCallbacker.h"
#include "BLEServiceExposeDelegate.h"

#ifndef __BLE_SERVICE_EXPOSE_H__
#define __BLE_SERVICE_EXPOSE_H__

class BLEServiceExpose {
public:
    BLEServiceExpose(std::unique_ptr<BLEService> pService);
    void setDelegate(BLEServiceExposeDelegate* delegate);
    void startService();
    void sendEvent(std::string msg);
    void sendLux(float iso, float f, float ss, float lv, float ev, float lux);
    void sendRGB(float r, float g, float b, float ir);
    
private:
    std::unique_ptr<BLEServiceExposeDelegate> delegate_;
    std::unique_ptr<BLEService> pService_;
    std::shared_ptr<BLE2902> pBLE2902_;

    std::unique_ptr<BLECharacteristic> pCharacteristicEvent_;
    std::unique_ptr<BLECharacteristic> pCharacteristicLux_;
    std::unique_ptr<BLECharacteristic> pCharacteristicRGB_;
    std::unique_ptr<BLECharacteristic> pCharacteristicISO_;
    
    CharacteristicCallbacker cbRecvEvent_;
    CharacteristicCallbacker cbRecvISO_;

}; // BLEServiceExpose

#endif __BLE_SERVICE_EXPOSE_H__
