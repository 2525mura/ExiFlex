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
    // init Exipander driver
    expander = new PCF8574(0x20);
    // Set expander's all outputs to Hi
    expander->begin();
    expander->write8(0xFF);
    // PotentioValue to fNum LUT
    for(int adcValue=0; adcValue<256; adcValue++) {
        // scalling -1 to 9
        float dialValue = adcValue / 256.0 * 10.0 - 1.0;
        float squrt2 = sqrt(2.0);
        float fNum = pow(squrt2, dialValue);
        fNumLut[adcValue] = fNum;
    }
    exposureMeterModel = new ExposureMeterModel();
    colorMeterModel = new ColorMeterModel();
    bool sensorConnected = exposureMeterModel->initLuxSensor();
    colorMeterModel->initColorSensor();
}

void FrontPanelController::ledOn(int ledNo) {
    if(ledNo<=0 || ledNo>3) return;
    expander->write(ledNo + 3, LOW);
}

void FrontPanelController::ledOff(int ledNo) {
    if(ledNo<=0 || ledNo>3) return;
    expander->write(ledNo + 3, HIGH);
}

byte FrontPanelController::getRotarySwValue() {
    byte value = expander->read8() & 0x0F;
    return value;
}

byte FrontPanelController::getPotentioValue() {
    // quantize to 8bit
    return analogRead(A0) >> 4;
}

float FrontPanelController::getProperEV() {
    // TODO: ISO値を可変にする
    
    String strSs = shutterSpeedLut[getRotarySwValue()];
    if(strSs.equals("0")) {
        return 0.0;
    }

    float iso = 100.0;
    float fnum = fNumLut[getPotentioValue()];
    float ss = strSs.toFloat();

    float isoFix = log2(iso / 100.0);
    float ev = 2 * log2(fnum) + log2(ss) - isoFix;
    return ev;
}

void FrontPanelController::indicateExposure(float dEv) {
    if(dEv >= 0.5) {
        ledOn(1);
    } else {
        ledOff(1);
    }
    if(dEv > -1.0 && dEv < 1.0) {
        ledOn(2);
    } else {
        ledOff(2);
    }
    if(dEv <= -0.5) {
        ledOn(3);
    } else {
        ledOff(3);
    }
}

void FrontPanelController::onReceiveCharacteristic(String uuid, String alias, String data) {
    if(alias.equals("event")) {
      // Do not lock the thread as the BLE background task will stop
    }
}

void FrontPanelController::onMeasureLuxEvent() {
    // Exposure
    String ss = shutterSpeedLut[getRotarySwValue()];
    float f = fNumLut[getPotentioValue()];
    float ev = getProperEV();
    float lv = 0;
    float lux = 0;
    exposureMeterModel->measureEV(&lv, &lux);
    String message = "ISO:100 FNUM:" + String(f, 1) + " SS:" + ss + " LV:" + String(lv, 1) + " EV:" + String(ev, 1) + " LUX:" + String((int)lux);
    iEspBleService->sendMessage(CHARACTERISTIC_LUX_UUID, message);
    indicateExposure(lv - ev);
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
