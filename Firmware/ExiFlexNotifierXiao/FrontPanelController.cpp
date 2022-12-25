//
//  FrontPanelController.cpp
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "FrontPanelController.h"

FrontPanelController::FrontPanelController() {
  expander = new PCF8574(0x20);
  // Expanderの出力をAll HIにする
  expander->begin();
  expander->write8(0xFF);
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
