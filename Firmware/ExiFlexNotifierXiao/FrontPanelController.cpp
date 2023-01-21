//
//  FrontPanelController.cpp
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "FrontPanelController.h"

#define CHARACTERISTIC_FRONTPANEL_UUID "a0e1e288-94af-caca-f53a-cdf3b5656620"

FrontPanelController::FrontPanelController(IEspBleService* iEspBleService) {
  // DI of EspBleService
  this->iEspBleService = iEspBleService;
  this->iEspBleService->AddCharacteristicUuid(CHARACTERISTIC_FRONTPANEL_UUID);
  // init Exipander driver
  expander = new PCF8574(0x20);
  // Set expander's all outputs to Hi
  expander->begin();
  expander->write8(0xFF);
  // Setting initial value
  this->lastSsFnum = "";
  // PotentioValue to fNum LUT
  for(int adcValue=0; adcValue<256; adcValue++) {
    // scalling -1 to 9
    float dialValue = adcValue / 256.0 * 10.0 - 1.0;
    float squrt2 = sqrt(2.0);
    float fNum = pow(squrt2, dialValue);
    fNumLut[adcValue] = fNum;
  }
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

void FrontPanelController::LoopTask(void *pvParameters) {

  // polling thread
  while(1) {
    String ss = shutterSpeedLut[getRotarySwValue()];
    float f = fNumLut[getPotentioValue()];
    String ssf = ss + " " + String(f, 1);
    if(!ssf.equals(this->lastSsFnum)) {
      this->iEspBleService->SendMessage(CHARACTERISTIC_FRONTPANEL_UUID, ssf);
      this->lastSsFnum = ssf;
    }
    Serial.println(ssf);
    delay(100);
  }
}
