//
//  ExposureMeterModel.h
//  Exiflex exposure meter model
//
//  Created by 村井慎太郎 on 2023/01/22.
//

#include "Arduino.h"
#include "AE_TSL2572.h"

class ExposureMeterModel {
  public:
    ExposureMeterModel();
    bool initLuxSensor();
    float measureLux();
    float measureEV();

  private:
    // Luxセンサー
    AE_TSL2572 tsl2572;
    bool luxSensorConnected = false;
};
