//
//  ExposureMeterModel.h
//  Exiflex exposure meter model
//
//  Created by 村井慎太郎 on 2023/01/22.
//

#include "Arduino.h"
#include "PCF8574.h"
#include "../Infrastructures/AE_TSL2572.h"

class ExposureMeterModel {
 public:
  ExposureMeterModel();
  bool initLuxSensor();
  void getExposure(String& ssOut, float* fnumOut, float* evOut, float* lvOut, float* luxOut);
  void indicateExposure(float dEv);
  void ledOffAll();

 private:
  float measureLux();
  void ledOn(int ledNo);
  void ledOff(int ledNo);
  byte getRotarySwValue();
  byte getPotentioValue();
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
  // IOエキスパンダー
  PCF8574 expander;
  // Luxセンサー
  AE_TSL2572 tsl2572;
  bool luxSensorConnected = false;
};
