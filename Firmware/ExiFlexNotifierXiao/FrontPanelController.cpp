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
  this->rotarySwValue = 0;
  this->potentioValue = 0;
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

uint16_t FrontPanelController::getPotentioValue() {
  return analogRead(A0);
}

void FrontPanelController::LoopTask(void *pvParameters) {

  // polling thread
  while(1) {
    bool isUpdate = false;
    byte rotarySwValue = this->getRotarySwValue();
    uint16_t potentioValue = this->getPotentioValue();
    
    if(this->rotarySwValue != rotarySwValue) {
      this->rotarySwValue = rotarySwValue;
      isUpdate = true;
    }
    if(this->potentioValue != potentioValue) {
      this->potentioValue = potentioValue;
      isUpdate = true;
    }

    if(isUpdate) {
      String message = String(rotarySwValue, DEC) + " " + String(potentioValue, DEC);
      this->iEspBleService->SendMessage(CHARACTERISTIC_FRONTPANEL_UUID, message);
    }
    delay(100);
  }
}
