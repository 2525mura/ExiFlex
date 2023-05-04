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

#ifndef __FRONT_PANEL_CONTROLLER_H__
#define __FRONT_PANEL_CONTROLLER_H__

typedef enum {
  EVENT_SHUTTER,
  EVENT_LUX,
  EVENT_RGB
} EventID;

class FrontPanelController: public EspBlePeripheralDelegate {
  public:
    FrontPanelController(IEspBleService* iEspBleService);
    void onMeasureLuxEvent();
    void onMeasureRGBEvent();
    void onShutterEvent();
    void onReceiveCharacteristic(String uuid, String alias, String data);
    static void runOnEvent(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data);
    void init();
    void shutdown();
    esp_event_loop_handle_t loopHandle;

  private:
    // DI from constructor
    IEspBleService* iEspBleService = NULL;
    // ExposureMeterModel
    ExposureMeterModel* exposureMeterModel = NULL;
    // ColorMeterModel
    ColorMeterModel* colorMeterModel = NULL;
};

#endif __FRONT_PANEL_CONTROLLER_H__
