//
//  FrontPanelController.cpp
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "FrontPanelController.h"

#define CHARACTERISTIC_LUX_UUID "16cf81e3-0212-58b9-0380-0dbc6b54c51d"

FrontPanelController::FrontPanelController(IEspBleService* iEspBleService) {
  // DI of EspBleService
  this->iEspBleService = iEspBleService;
  this->iEspBleService->AddCharacteristicUuid(CHARACTERISTIC_LUX_UUID);
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
}

void FrontPanelController::LedOn(int ledNo) {
  if(ledNo<=0 || ledNo>3) return;
  expander->write(ledNo + 3, LOW);
}

void FrontPanelController::LedOff(int ledNo) {
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

float FrontPanelController::getProperLV() {
  // TODO: ISO値を可変にする
  
  String strSs = shutterSpeedLut[getRotarySwValue()];
  if(strSs.equals("0")) {
    return 0.0;
  }

  float iso = 100.0;
  float fnum = fNumLut[getPotentioValue()];
  float ss = strSs.toFloat();

  float isoFix = log2(iso / 100.0);
  float lv = 2 * log2(fnum) + log2(ss) - isoFix;
  return lv;
}

void FrontPanelController::LoopTask(void *pvParameters) {
  bool sensorConnected = exposureMeterModel->initLuxSensor();
  // polling thread
  while(1) {
    String ss = shutterSpeedLut[getRotarySwValue()];
    float f = fNumLut[getPotentioValue()];
    float lv = getProperLV();
    float ev = exposureMeterModel->measureEV();
    String message = "ISO:100 FNUM:" + String(f, 1) + " SS:" + ss + " LV:" + String(lv, 1) + " EV:" + String(ev, 1);
    this->iEspBleService->SendMessage(CHARACTERISTIC_LUX_UUID, message);
    Serial.println(message);
    delay(100);
  }
}
