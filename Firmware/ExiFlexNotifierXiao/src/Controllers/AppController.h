//
//  AppController.h
//  Exiflex firmware app main controller
//
//  Created by 2525mura on 2022/12/24.
//

#include <memory>
#include <BLEDevice.h>
#include "Arduino.h"
#include "../Views/BLEServiceExpose.h"
#include "../Views/BLEServiceExposeDelegate.h"
#include "../Views/EventLoopDelegate.h"
#include "../Models/ExposureMeterModel.h"
#include "../Models/ColorMeterModel.h"

#ifndef __APP_CONTROLLER_H__
#define __APP_CONTROLLER_H__

class AppController: public BLEServerCallbacks, public BLEServiceExposeDelegate, public EventLoopDelegate {
  public:
    AppController();
    void init();
    void shutdown();

  private:
    void onMeasureLuxEvent() override;
    void onMeasureRGBEvent() override;
    void onShutterEvent() override;
    void onConnect(BLEServer* pServer) override;
    void onDisconnect(BLEServer* pServer) override;
    void onRecvEvent(std::string msg) override;
    void onRecvISO(int iso) override;
    // BLE server
    std::unique_ptr<BLEServer> pServer;
    // BLE service stub
    std::unique_ptr<BLEServiceExpose> bleServiceExpose;
    // ExposureMeterModel
    std::unique_ptr<ExposureMeterModel> exposureMeterModel;
    // ColorMeterModel
    std::unique_ptr<ColorMeterModel> colorMeterModel;
    bool bleConnected = false;
};

#endif __APP_CONTROLLER_H__
