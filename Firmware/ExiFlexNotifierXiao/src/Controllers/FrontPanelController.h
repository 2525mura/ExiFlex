//
//  FrontPanelController.h
//  Exiflex front panel controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "Arduino.h"
#include "../Infrastructures/EspBleService.h"
#include "../Infrastructures/EspBlePeripheralDelegate.h"
#include "../Models/ExposureMeterModel.h"
#include "../Models/ColorMeterModel.h"

class FrontPanelController: public EspBlePeripheralDelegate {
  public:
    FrontPanelController(IEspBleService* iEspBleService);
    void onMeasureLuxEvent();
    void onMeasureRGBEvent();
    void onShutterEvent();
    void onReceiveCharacteristic(String uuid, String alias, String data);
    void shutdown();

  private:
    // DI from constructor
    IEspBleService* iEspBleService = NULL;
    // ExposureMeterModel
    ExposureMeterModel* exposureMeterModel = NULL;
    // ColorMeterModel
    ColorMeterModel* colorMeterModel = NULL;
};
