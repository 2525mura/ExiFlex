//
//  ExposureMeterModel.cpp
//  Exiflex exposure meter model
//
//  Created by 村井慎太郎 on 2023/01/22.
//

#include "ExposureMeterModel.h"

ExposureMeterModel::ExposureMeterModel() {
}

bool ExposureMeterModel::initLuxSensor() {
    //ゲイン　0～ 5 (x0.167 , x1.0 , x1.33 , x8 , x16 , x120)
    byte gain_step = 1;
    //積分時間のカウンタ(0xFFから減るごとに+2.73ms)
    //0xFF：  1サイクル(約 2.73ms)
    //0xDB： 37サイクル(約  101ms)
    //0xC0： 64サイクル(約  175ms)
    //0x00：256サイクル(約  699ms)
    byte atime_cnt = 0xC0;

    if (tsl2572.CheckID()) {
    //ゲインを設定
    tsl2572.SetGain(gain_step);
    //積分時間を設定
    tsl2572.SetIntegralTime(atime_cnt);

    //計測開始
    tsl2572.Reset();
    delay(100);
    }
    else {
        luxSensorConnected = false;
        Serial.println("Failed. Check connection!!");
    return false;
    }
    luxSensorConnected = true;
    return true;
}

float ExposureMeterModel::measureLux() {
    if(!luxSensorConnected) {
        return 0.0;
    }
    //TSL2572.GetLux16()で照度を取得
    uint16_t lux = tsl2572.GetLux16();
    //自動ゲイン調整
    // TSL2572.SetGainAuto();
    return (float)lux;
}

void ExposureMeterModel::measureEV(float* ev, float* lux) {
    if(!luxSensorConnected) {
        return;
    }
    *lux = measureLux();
    *ev = log2(*lux / 2.5);
}