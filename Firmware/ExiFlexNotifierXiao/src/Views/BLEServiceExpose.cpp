/**
 * This code was generated by BlueJinja
 *
 */

#include "BLEServiceExpose.h"

BLEServiceExpose::BLEServiceExpose(std::unique_ptr<BLEService> pService) :
    pService_(std::move(pService)),
    pBLE2902_(new BLE2902())
{
    // Create BLE Characteristics
    // Event
    auto tmpEvent = pService_->createCharacteristic("beb5483e-36e1-4688-b7f5-ea07361b26a8",
                  BLECharacteristic::PROPERTY_READ   |
                  BLECharacteristic::PROPERTY_WRITE  |
                  BLECharacteristic::PROPERTY_NOTIFY |
                  BLECharacteristic::PROPERTY_INDICATE
                  );
    pCharacteristicEvent_.reset(tmpEvent);
    pCharacteristicEvent_->addDescriptor(pBLE2902_.get());
    // Lux
    auto tmpLux = pService_->createCharacteristic("16cf81e3-0212-58b9-0380-0dbc6b54c51d",
                  BLECharacteristic::PROPERTY_READ   |
                  BLECharacteristic::PROPERTY_WRITE  |
                  BLECharacteristic::PROPERTY_NOTIFY |
                  BLECharacteristic::PROPERTY_INDICATE
                  );
    pCharacteristicLux_.reset(tmpLux);
    pCharacteristicLux_->addDescriptor(pBLE2902_.get());
    // RGB
    auto tmpRGB = pService_->createCharacteristic("67f46ec5-3d54-54c2-ae2d-fb318a4973b0",
                  BLECharacteristic::PROPERTY_READ   |
                  BLECharacteristic::PROPERTY_WRITE  |
                  BLECharacteristic::PROPERTY_NOTIFY |
                  BLECharacteristic::PROPERTY_INDICATE
                  );
    pCharacteristicRGB_.reset(tmpRGB);
    pCharacteristicRGB_->addDescriptor(pBLE2902_.get());
    // ISO
    auto tmpISO = pService_->createCharacteristic("241abff2-5d09-b5a3-4a77-cfc19cfac587",
                  BLECharacteristic::PROPERTY_READ   |
                  BLECharacteristic::PROPERTY_WRITE  |
                  BLECharacteristic::PROPERTY_NOTIFY |
                  BLECharacteristic::PROPERTY_INDICATE
                  );
    pCharacteristicISO_.reset(tmpISO);
    pCharacteristicISO_->addDescriptor(pBLE2902_.get());
    
    // Set receive delegate
    cbRecvEvent_.setFunc([this](std::string msg) {
        delegate_->onRecvEvent(msg);
    });
    pCharacteristicEvent_->setCallbacks(&cbRecvEvent_);
    cbRecvISO_.setFunc([this](std::string msg) {
        int* buff = (int*)msg.c_str();
        delegate_->onRecvISO(buff[0]);
    });
    pCharacteristicISO_->setCallbacks(&cbRecvISO_);
}


void BLEServiceExpose::sendEvent(std::string msg) {
    
    pCharacteristicEvent_->setValue(msg);
    pCharacteristicEvent_->notify();
}
void BLEServiceExpose::sendLux(float iso, float f, float ss, float lv, float ev, float lux) {
    
    float buff[6];
    buff[0] = iso;
    buff[1] = f;
    buff[2] = ss;
    buff[3] = lv;
    buff[4] = ev;
    buff[5] = lux;
    
    pCharacteristicLux_->setValue((uint8_t*)buff, 24);
    pCharacteristicLux_->notify();
}
void BLEServiceExpose::sendRGB(float r, float g, float b, float ir) {
    
    float buff[4];
    buff[0] = r;
    buff[1] = g;
    buff[2] = b;
    buff[3] = ir;
    
    pCharacteristicRGB_->setValue((uint8_t*)buff, 16);
    pCharacteristicRGB_->notify();
}

void BLEServiceExpose::setDelegate(BLEServiceExposeDelegate* delegate) {
    delegate_.reset(delegate);
}

void BLEServiceExpose::startService() {
    // Start the service
    pService_->start();

    // Start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(pService_->getUUID());
    pAdvertising->setScanResponse(false);
    pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
    BLEDevice::startAdvertising();
}