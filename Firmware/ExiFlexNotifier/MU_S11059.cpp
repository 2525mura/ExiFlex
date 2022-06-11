//
//  MU_S11059.cpp
//  MU_S11059 Driver
//
//  Created by 村井慎太郎 on 2022/06/26.
//

#include "MU_S11059.h"

MU_S11059::MU_S11059() {
  gain_step = 1;
  again = 1.0;
  atime_cnt = 0xFF;

  adc0 = 0;
  adc1 = 0;
}

bool MU_S11059::CheckID() {
  //check S11059 ID
  if (ReadReg(S11059_ID) == 0x34) {
    return 1;
  }
  return 0;
}

void MU_S11059::Reset() {
  WriteIntegralTime();
  WriteGain();
  WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_ENABLE, S11059_AEN | S11059_PON);
  ReadAdc();
}

void MU_S11059::WriteReg(uint8_t reg, uint8_t dat) {
  Wire.beginTransmission(S11059_ADR);
  Wire.write(reg);
  Wire.write(dat);
  Wire.endTransmission();
}

uint8_t MU_S11059::ReadReg(uint8_t reg) {
  uint8_t dat;
  Wire.beginTransmission(S11059_ADR);
  Wire.write(S11059_COMMAND | S11059_TYPE_INC | reg);
  Wire.endTransmission();
  Wire.requestFrom(S11059_ADR, (uint8_t)1);
  dat = Wire.read();
  return dat;
}

void MU_S11059::SetIntegralTime(uint8_t a) {
  atime_cnt = a;
}

void MU_S11059::WriteIntegralTime() {
  WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_ATIME, atime_cnt);
  atime = atime_cnt;
}

void MU_S11059::SetGain(uint8_t a) {
  gain_step = a;
}

void MU_S11059::WriteGain() {
  switch (gain_step) {
    case 0x00:// 1/6
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x00);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x04);
      again = 0.1667;
      break;
    case 0x01:// x1
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x00);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x00);
      again = 1.0;
      break;
    case 0x02:// x8/6
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x01);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x04);
      again = 1.333;
      break;
    case 0x03: // x8
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x01);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x00);
      again = 8.0;
      break;
    case 0x04: // x16
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x00);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x02);
      again = 16.0;
      break;
    case 0x05: // x120
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x00);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x03);
      again = 120.0;
      break;
    default : //set x1
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONTROL, 0x00);
      WriteReg(S11059_COMMAND | S11059_TYPE_INC | S11059_CONFIG, 0x00);
      again = 1.0;
      break;
  }
}

void MU_S11059::SetGainAuto(){
    //Only for module operation check.
    //Do not use production operation.

    if(atime < 64){
      uint16_t temp = 1024 * atime;
      limit_lower = temp * coefficient_lower;
      limit_upper = temp * coefficient_upper;
    }
    else{
      limit_lower = 65535 * coefficient_lower;
      limit_upper = 65535 * coefficient_upper;
    }
    
    if((adc0 < limit_lower) && (gain_step < 5)){
      gain_step++;
    }
    else if((adc0 > limit_upper) && (gain_step > 0)){
      gain_step--;
    }
    Reset();
}


void MU_S11059::ReadAdc() {
  uint8_t dat[4];
  Wire.beginTransmission(S11059_ADR);
  Wire.write(S11059_COMMAND | S11059_TYPE_INC | S11059_C0DATA);
  Wire.endTransmission();

  Wire.requestFrom(S11059_ADR, (uint8_t)4);
  for (int i = 0; i < 4; i++) {
    dat[i] = Wire.read();
  }
  adc0 = (dat[1] << 8) | dat[0];
  adc1 = (dat[3] << 8) | dat[2];
}

float MU_S11059::CalcLux() {
  float cpl = 0.0;
  float lux1 = 0.0;
  float lux2 = 0.0;
  cpl = (2.73 * (256 - atime) * again) / (60.0);
  lux1 = ((adc0 * 1.00) - (adc1 * 1.87)) / cpl;
  lux2 = ((adc0 * 0.63) - (adc1 * 1.00)) / cpl;
  if ((lux1 <= 0) && (lux2 <= 0)) {
    return 0.0;
  }
  else if (lux1 > lux2) {
    return lux1;
  }
  else if (lux1 < lux2) {
    return lux2;
  }
}

uint16_t MU_S11059::GetLux16() {
  return (uint16_t)GetLux();
}

float MU_S11059::GetLux() {
  ReadAdc();
  return CalcLux();
}

uint8_t MU_S11059::GetGainStep() {
  return gain_step;
}

uint8_t MU_S11059::GetIntegrationTime() {
  return atime;
}

