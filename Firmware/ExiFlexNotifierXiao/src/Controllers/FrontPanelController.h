//
//  FrontPanelController.h
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "Arduino.h"
#include "PCF8574.h"
#include "../Infrastructures/EspBleService.h"
#include "../Infrastructures/EspBlePeripheralDelegate.h"
#include "../Models/ExposureMeterModel.h"
#include "../Models/ColorMeterModel.h"

class FrontPanelController: public EspBlePeripheralDelegate {
  public:
    FrontPanelController(IEspBleService* iEspBleService);
    void LoopTask(void *pvParameters);
    void LedOn(int ledNo);
    void LedOff(int ledNo);
    void onReceiveCharacteristic(String uuid, String alias, String data);

  private:
    // DI from constructor
    IEspBleService* iEspBleService = NULL;
    // IOエキスパンダー
    PCF8574* expander = NULL;
    // ExposureMeterModel
    ExposureMeterModel* exposureMeterModel = NULL;
    // ColorMeterModel
    ColorMeterModel* colorMeterModel = NULL;
    const String shutterSpeedLut[16] = {
      "0",
      "0.125",
      "0.25",
      "0.5",
      "1",
      "2",
      "4",
      "8",
      "15",
      "30",
      "60",
      "125",
      "250",
      "500",
      "1000",
      "2000"
    };
    float fNumLut[256];
    byte getRotarySwValue();
    byte getPotentioValue();
    float getProperEV();
    void indicateExposure(float dEv);
};
