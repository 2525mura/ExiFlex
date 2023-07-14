//
//  AppController.cpp
//  Exiflex firmware app main controller
//
//  Created by 2525mura on 2022/12/24.
//

#include "AppController.h"

// Service UUID
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"

AppController::AppController() {
  exposureMeterModel.reset(new ExposureMeterModel());
  colorMeterModel.reset(new ColorMeterModel());
}

void AppController::init() {
  // Create the BLE Device
  BLEDevice::init("ExiFlex");
  // Create the BLE Server
  pServer.reset(BLEDevice::createServer());
  pServer->setCallbacks(this);
  // Create the BLE Service
  auto pService = std::unique_ptr<BLEService>(pServer->createService(SERVICE_UUID));
  bleServiceExpose.reset(new BLEServiceExpose(std::move(pService)));
  bleServiceExpose->setDelegate(this);
  bleServiceExpose->startService();
  // init models
  bool sensorConnected = exposureMeterModel->initLuxSensor();
  colorMeterModel->initColorSensor();
}

void AppController::shutdown() {
  exposureMeterModel->ledOffAll();
}

void AppController::onMeasureLuxEvent() {
  // Exposure
  String ss;
  float f;
  float ev;
  float lv;
  float lux;
  exposureMeterModel->getExposure(ss, &f, &ev, &lv, &lux);
  bleServiceExpose->sendLux(100, f, ss.toFloat(), lv, ev, lux);
  exposureMeterModel->indicateExposure(lv - ev);
}

void AppController::onMeasureRGBEvent() {
    // Color
    float r, g, b, ir;
    colorMeterModel->measureColor(&r, &g, &b, &ir);
    bleServiceExpose->sendRGB(r, g, b, ir);
}

void AppController::onShutterEvent() {
  if(bleConnected) {
    bleServiceExpose->sendEvent("SHUTTER");
  }
}

void AppController::onConnect(BLEServer* pServer) {
    bleConnected = true;
}

void AppController::onDisconnect(BLEServer* pServer) {
    bleConnected = false;
    // restart advertising
    pServer->startAdvertising();
}

void AppController::onRecvEvent(std::string msg) {
}

void AppController::onRecvISO(int iso) {
}
