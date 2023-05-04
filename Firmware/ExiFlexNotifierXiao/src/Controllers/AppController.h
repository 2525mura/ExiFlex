//
//  AppController.h
//  Exiflex firmware app main controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include <memory>
#include "Arduino.h"
#include "../Infrastructures/EspBleService.h"
#include "../Infrastructures/EspBlePeripheralDelegate.h"
#include "../Models/ExposureMeterModel.h"
#include "../Models/ColorMeterModel.h"

#ifndef __APP_CONTROLLER_H__
#define __APP_CONTROLLER_H__

typedef enum {
  EVENT_SHUTTER,
  EVENT_LUX,
  EVENT_RGB
} EventID;

class AppController: public EspBlePeripheralDelegate {
  public:
    AppController();
    void init();
    void shutdown();
    esp_event_loop_handle_t loopHandle;

  private:
    static void runOnEvent(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data);
    void onMeasureLuxEvent();
    void onMeasureRGBEvent();
    void onShutterEvent();
    void onReceiveCharacteristic(String uuid, String alias, String data);
    // BLE service
    std::unique_ptr<IEspBleService> iEspBleService;
    // ExposureMeterModel
    std::unique_ptr<ExposureMeterModel> exposureMeterModel;
    // ColorMeterModel
    std::unique_ptr<ColorMeterModel> colorMeterModel;
};

#endif __APP_CONTROLLER_H__
