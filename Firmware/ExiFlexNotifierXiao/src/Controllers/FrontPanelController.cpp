//
//  FrontPanelController.cpp
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "FrontPanelController.h"

#define CHARACTERISTIC_EVENT_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_LUX_UUID "16cf81e3-0212-58b9-0380-0dbc6b54c51d"
#define CHARACTERISTIC_RGB_UUID "67f46ec5-3d54-54c2-ae2d-fb318a4973b0"

FrontPanelController::FrontPanelController(IEspBleService* iEspBleService) {
    // DI of EspBleService
    this->iEspBleService = iEspBleService;
    this->iEspBleService->setDelegate(this);
    this->iEspBleService->addCharacteristicUuid(CHARACTERISTIC_EVENT_UUID, "event");
    this->iEspBleService->addCharacteristicUuid(CHARACTERISTIC_LUX_UUID, "lux");
    this->iEspBleService->addCharacteristicUuid(CHARACTERISTIC_RGB_UUID, "xyz");
    exposureMeterModel = new ExposureMeterModel();
    colorMeterModel = new ColorMeterModel();
    bool sensorConnected = exposureMeterModel->initLuxSensor();
    colorMeterModel->initColorSensor();
}

void FrontPanelController::onReceiveCharacteristic(String uuid, String alias, String data) {
    if(alias.equals("event")) {
      // Do not lock the thread as the BLE background task will stop
    }
}

void FrontPanelController::onMeasureLuxEvent() {
  // Exposure
  String ss;
  float f;
  float ev;
  float lv;
  float lux;
  exposureMeterModel->getExposure(ss, &f, &ev, &lv, &lux);
  String message = "ISO:100 FNUM:" + String(f, 1) + " SS:" + ss + " LV:" + String(lv, 1) + " EV:" + String(ev, 1) + " LUX:" + String((int)lux);
  iEspBleService->sendMessage(CHARACTERISTIC_LUX_UUID, message);
  exposureMeterModel->indicateExposure(lv - ev);
}

void FrontPanelController::onMeasureRGBEvent() {
    // Color
    float r, g, b, ir;
    colorMeterModel->measureColor(&r, &g, &b, &ir);
    String messageColor = "R:" + String((int)r) + " G:" + String((int)g) + " B:" + String((int)b) + " IR:" + String((int)ir);
    iEspBleService->sendMessage(CHARACTERISTIC_RGB_UUID, messageColor);
}

void FrontPanelController::onShutterEvent() {
    iEspBleService->sendMessage(CHARACTERISTIC_EVENT_UUID, "SHUTTER");
}
