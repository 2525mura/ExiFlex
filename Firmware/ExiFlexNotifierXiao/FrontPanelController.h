//
//  FrontPanelController.h
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "Arduino.h"
#include "PCF8574.h"

class FrontPanelController {
  public:
    FrontPanelController();
    void LedOn(int ledNo);
    void LedOff(int ledNo);
    byte getRotarySwValue();
    uint16_t getPotentioValue();

  private:
    // IOエキスパンダー
    PCF8574* expander = NULL;
};
