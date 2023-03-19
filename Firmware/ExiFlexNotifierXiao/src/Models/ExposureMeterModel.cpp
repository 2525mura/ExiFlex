//
//  ExposureMeterModel.cpp
//  Exiflex exposure meter model
//
//  Created by 村井慎太郎 on 2023/01/22.
//

#include "ExposureMeterModel.h"

ExposureMeterModel::ExposureMeterModel() {
  // PotentioValue to fNum LUT
  for(int adcValue=0; adcValue<256; adcValue++) {
    // scalling -1 to 9
    float dialValue = adcValue / 256.0 * 10.0 - 1.0;
    float squrt2 = sqrt(2.0);
    float fNum = pow(squrt2, dialValue);
    fNumLut[adcValue] = fNum;
  }
  // Set expander's all outputs to Hi
  expander.begin();
  expander.write8(0xFF);
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

void ExposureMeterModel::ledOn(int ledNo) {
  if(ledNo<0 || ledNo>2) return;
  expander.write(ledNo + 4, LOW);
}

void ExposureMeterModel::ledOff(int ledNo) {
  if(ledNo<0 || ledNo>2) return;
  expander.write(ledNo + 4, HIGH);
}

void ExposureMeterModel::ledOffAll() {
  ledOff(0);
  ledOff(1);
  ledOff(2);
}

byte ExposureMeterModel::getRotarySwValue() {
  byte value = expander.read8() & 0x0F;
  return value;
}

byte ExposureMeterModel::getPotentioValue() {
  // quantize to 8bit
  return analogRead(A0) >> 4;
}

void ExposureMeterModel::indicateExposure(float dEv) {
  if(dEv >= 0.3) {
    ledOn(0);
  } else {
    ledOff(0);
  }
  if(dEv > -1.1 && dEv < 1.1) {
    ledOn(1);
  } else {
    ledOff(1);
  }
  if(dEv <= -0.3) {
    ledOn(2);
  } else {
    ledOff(2);
  }
}

void ExposureMeterModel::getExposure(String& ssOut, float* fnumOut, float* evOut, float* lvOut, float* luxOut) {
  // computed standard exposure
  String ssDec = shutterSpeedLut[getRotarySwValue()];
  float ss = ssDec.toFloat();
  float fnum = fNumLut[getPotentioValue()];
  // TODO: ISO値を可変にする
  float iso = 100.0;
  float isoFix = log2(iso / 100.0);
  float ev;
  if(ssDec == "0") {
    // Bulb mode
    ev = 0;
  } else {
    ev = 2 * log2(fnum) + log2(ss) - isoFix;
  }
  // actual exposure
  float lux = measureLux();
  float lv = log2(lux / 2.5);
  // output result
  ssOut = ssDec;
  *fnumOut = fnum;
  *evOut = ev;
  *lvOut = lv;
  *luxOut = lux;
}
