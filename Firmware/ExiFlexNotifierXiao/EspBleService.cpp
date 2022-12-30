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

void EspBleService::Setup() {
  // Create the BLE Device
  BLEDevice::init("ExiFlex");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks(this));

  // Create the BLE Service
  pService = pServer->createService(SERVICE_UUID);

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

void EspBleService::AddCharacteristicUuid(String characteristicUuid) {
  // Create a BLE Characteristic
  BLECharacteristic* pCharacteristic = pService->createCharacteristic(
                      characteristicUuid.c_str(),
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );
  // Create BLEDescriptor instance by smart pointer
  std::shared_ptr<BLE2902> ble2902(new BLE2902());
  pCharacteristic->addDescriptor(ble2902.get());
  // Store in hashtable
  bleCharacteristicMap[std::string(characteristicUuid.c_str())] = pCharacteristic;
}

void EspBleService::SendMessage(String characteristicUuid, String message) {
  BLECharacteristic* pCharacteristic = bleCharacteristicMap[std::string(characteristicUuid.c_str())];
  pCharacteristic->setValue(message.c_str());
  // notifyすると落ちる
  //pCharacteristic->notify();
}

void EspBleService::LoopTask(void *pvParameters) {
  while(1) {
    // notify changed value
    if (deviceConnected) {
      delay(100); // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
    }
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
        // do stuff here on connecting
        oldDeviceConnected = deviceConnected;
    }
  }
}
