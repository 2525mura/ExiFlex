//
//  AppController.cpp
//  Exiflex firmware app main controller
//
//  Created by 村井慎太郎 on 2022/12/24.
//

#include "AppController.h"

#define CHARACTERISTIC_EVENT_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_LUX_UUID "16cf81e3-0212-58b9-0380-0dbc6b54c51d"
#define CHARACTERISTIC_RGB_UUID "67f46ec5-3d54-54c2-ae2d-fb318a4973b0"
ESP_EVENT_DEFINE_BASE(APP_EVENT_BASE);

AppController::AppController() {
  iEspBleService.reset(new EspBleService());
  exposureMeterModel.reset(new ExposureMeterModel());
  colorMeterModel.reset(new ColorMeterModel());
}

void AppController::init() {
  // init BLE service
  iEspBleService->setup();
  iEspBleService->setDelegate(this);
  iEspBleService->addCharacteristicUuid(CHARACTERISTIC_EVENT_UUID, "event");
  iEspBleService->addCharacteristicUuid(CHARACTERISTIC_LUX_UUID, "lux");
  iEspBleService->addCharacteristicUuid(CHARACTERISTIC_RGB_UUID, "xyz");
  iEspBleService->startService();
  // init models
  bool sensorConnected = exposureMeterModel->initLuxSensor();
  colorMeterModel->initColorSensor();
  // Main event loop init
  esp_event_loop_args_t loop_args = {
      .queue_size = 32,
      .task_name = "AppTask",
      .task_priority = uxTaskPriorityGet(NULL) + 1,
      .task_stack_size = 8192,
      .task_core_id = CONFIG_ARDUINO_RUNNING_CORE
  };
  esp_event_loop_create(&loop_args, &loopHandle);
  esp_event_handler_register_with(loopHandle, APP_EVENT_BASE, EVENT_SHUTTER, runOnEvent, this);
  esp_event_handler_register_with(loopHandle, APP_EVENT_BASE, EVENT_LUX, runOnEvent, this);
  esp_event_handler_register_with(loopHandle, APP_EVENT_BASE, EVENT_RGB, runOnEvent, this);
}

void AppController::shutdown() {
  esp_event_handler_unregister_with(loopHandle, APP_EVENT_BASE, EVENT_SHUTTER, runOnEvent);
  esp_event_handler_unregister_with(loopHandle, APP_EVENT_BASE, EVENT_LUX, runOnEvent);
  esp_event_handler_unregister_with(loopHandle, APP_EVENT_BASE, EVENT_RGB, runOnEvent);
  esp_event_loop_delete(loopHandle);
  exposureMeterModel->ledOffAll();
}

void AppController::onReceiveCharacteristic(String uuid, String alias, String data) {
    if(alias.equals("event")) {
      // Do not lock the thread as the BLE background task will stop
    }
}

void AppController::onMeasureLuxEvent() {
  // Exposure
  String ss;
  float f;
  float ev;
  float lv;
  float lux;
  exposureMeterModel->getExposure(ss, &f, &ev, &lv, &lux);
  String message = "ISO:100 FNUM:" + String(f, 1) + " SS:" + ss + " LV:" + String(lv, 1) + " EV:" + String(ev, 1) + " LUX:" + String((int)lux);
  iEspBleService->sendMessage(CHARACTERISTIC_LUX_UUID, message);
  exposureMeterModel->indicateExposure(lv - ev);
}

void AppController::onMeasureRGBEvent() {
    // Color
    float r, g, b, ir;
    colorMeterModel->measureColor(&r, &g, &b, &ir);
    String messageColor = "R:" + String((int)r) + " G:" + String((int)g) + " B:" + String((int)b) + " IR:" + String((int)ir);
    iEspBleService->sendMessage(CHARACTERISTIC_RGB_UUID, messageColor);
}

void AppController::onShutterEvent() {
  if(iEspBleService->deviceConnected) {
    iEspBleService->sendMessage(CHARACTERISTIC_EVENT_UUID, "SHUTTER");
  }
}

// Main event handler
void AppController::runOnEvent(void* handler_arg, esp_event_base_t base, int32_t id, void* event_data) {
  if (!handler_arg) {
    return;
  }
  auto ctl = static_cast<AppController*>(handler_arg);
  switch (id) {
  case EVENT_SHUTTER:
    ctl->onShutterEvent();
    break;
  case EVENT_LUX:
    ctl->onMeasureLuxEvent();
    break;
  case EVENT_RGB:
    ctl->onMeasureRGBEvent();
    break;
  default:
    break;
  }
}
