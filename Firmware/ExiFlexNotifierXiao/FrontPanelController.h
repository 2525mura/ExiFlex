//
//  FrontPanelController.h
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "Arduino.h"
#include "EspBleService.h"
#include "PCF8574.h"

class FrontPanelController {
  public:
    FrontPanelController(IEspBleService* espBleService);
    void LoopTask(void *pvParameters);
    void LedOn(int ledNo);
    void LedOff(int ledNo);
    byte getRotarySwValue();
    uint16_t getPotentioValue();

  private:
    // DI from constructor
    IEspBleService* iEspBleService = NULL;
    // IOエキスパンダー
    PCF8574* expander = NULL;
    byte rotarySwValue;
    uint16_t potentioValue;
};
