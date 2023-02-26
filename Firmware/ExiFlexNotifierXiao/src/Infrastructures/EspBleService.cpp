//
//  EspBleService.cpp
//  Exiflex ESP BLE Service
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "EspBleService.h"

// Service UUID
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"

EspBleService::EspBleService() {

}

void EspBleService::setup() {
    // Create the BLE Device
    BLEDevice::init("ExiFlex");

    // Create the BLE Server
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(this);

    // Create the BLE Service
    pService = pServer->createService(SERVICE_UUID);
}

void EspBleService::startService() {
    // Start the service
    pService->start();
    
    // Start advertising
    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(false);
    pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
    BLEDevice::startAdvertising();
    Serial.println("Waiting a client connection to notify...");
}

void EspBleService::addCharacteristicUuid(String characteristicUuid, String alias) {
    // Create a BLE Characteristic
    BLECharacteristic* pCharacteristic = pService->createCharacteristic(
                        characteristicUuid.c_str(),
                        BLECharacteristic::PROPERTY_READ   |
                        BLECharacteristic::PROPERTY_WRITE  |
                        BLECharacteristic::PROPERTY_NOTIFY |
                        BLECharacteristic::PROPERTY_INDICATE
                      );
    // Set callback on message from master
    pCharacteristic->setCallbacks(this);
    // Create BLEDescriptor instance
    pCharacteristic->addDescriptor(new BLE2902());
    // Store in hashtable
    bleCharacteristicMap[std::string(characteristicUuid.c_str())] = new EspBleCharacteristicModel(pCharacteristic, alias);
}

void EspBleService::sendMessage(String characteristicUuid, String message) {
    BLECharacteristic* pCharacteristic = bleCharacteristicMap[std::string(characteristicUuid.c_str())]->getCharacteristic();
    pCharacteristic->setValue(message.c_str());
    pCharacteristic->notify();
}

void EspBleService::run(void *pvParameters) {
    while(1) {
        if (deviceConnected) {
            // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
            delay(100);
        } else if (!deviceConnected && oldDeviceConnected) {
            // disconnecting
            delay(500); // give the bluetooth stack the chance to get things ready
            pServer->startAdvertising(); // restart advertising
            Serial.println("start advertising");
            oldDeviceConnected = deviceConnected;
        } else if (deviceConnected && !oldDeviceConnected) {
            // connecting
            // do stuff here on connecting
            oldDeviceConnected = deviceConnected;
        } else {
            delay(100);
        }
    }
}

void EspBleService::onConnect(BLEServer* pServer) {
    deviceConnected = true;
}

void EspBleService::onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
}

void EspBleService::onWrite(BLECharacteristic *pCharacteristic) {
    std::string uuid = pCharacteristic->getUUID().toString();
    String alias = bleCharacteristicMap[uuid]->getAlias();
    String data = String(pCharacteristic->getValue().c_str());
    if(this->blePeripheraldelegate != NULL) {
        blePeripheraldelegate->onReceiveCharacteristic(String(uuid.c_str()), alias, data);
    }
}

void EspBleService::setDelegate(EspBlePeripheralDelegate* delegate) {
    this->blePeripheraldelegate = delegate;
}
