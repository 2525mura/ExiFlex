//
//  MU_S11059.cpp
//  MU_S11059 Driver
//
//  Created by 村井慎太郎 on 2022/06/26.
//

#include "MU_S11059.h"

MU_S11059::MU_S11059() {
  // ゲイン
  SetGain(S11059_GAIN_LOW);
  // 積分時間
  SetIntegralTime(S11059_INTTIME_175, 3120);
  // ADC
  adc_r  = 0;
  adc_g  = 0;
  adc_b  = 0;
  adc_ir = 0;
}

void MU_S11059::Reset() {
  // マニュアルタイミングレジスタ
  WriteReg(S11059_TIMINGH, atime_coefficient >> 8);
  WriteReg(S11059_TIMINGL, atime_coefficient & 0xFF);
  // コントロールレジスタ
  WriteReg(S11059_COMMAND, S11059_ADC_RESET | again_bit | S11059_MODE_MANU | atime_bit);
  WriteReg(S11059_COMMAND, again_bit | S11059_MODE_MANU | atime_bit);
}

void MU_S11059::WriteReg(uint8_t reg, uint8_t dat) {
  Wire.beginTransmission(S11059_ADR);
  Wire.write(reg);
  Wire.write(dat);
  Wire.endTransmission();
}

void MU_S11059::SetGain(uint8_t ag) {
  switch (ag)
  {
  case S11059_GAIN_LOW:
    again = 1.0;
    break;
  case S11059_GAIN_HIGH:
    again = 10.0;
    break;
  default:
    break;
  }
  again_bit = ag;
}

void MU_S11059::SetIntegralTime(uint8_t at, uint16_t at_coef) {
  switch (at)
  {
  case S11059_INTTIME_175:
    atime = 0.175 * at_coef;
    break;
  case S11059_INTTIME_2800:
    atime = 2.8 * at_coef;
    break;
  case S11059_INTTIME_44800:
    atime = 44.8 * at_coef;
    break;
  case S11059_INTTIME_358400:
    atime = 358.4 * at_coef;
    break;
  default:
    break;
  }
  atime_bit = at;
  atime_coefficient = at_coef;
}

void MU_S11059::ReadAdc() {
  // 5ページ目 フォーマット ->「待機」 参照
  Wire.beginTransmission(S11059_ADR);
  Wire.write(S11059_RDATAH);
  Wire.endTransmission(false);
  uint8_t dat[8];
  Wire.requestFrom(S11059_ADR, (uint8_t)8);
  for (int i = 0; i < 8; i++) {
    dat[i] = Wire.read();
  }
  adc_r  = (dat[0] << 8) | dat[1];
  adc_g  = (dat[2] << 8) | dat[3];
  adc_b  = (dat[4] << 8) | dat[5];
  adc_ir = (dat[6] << 8) | dat[7];
}

ColorLux MU_S11059::CalcLux() {
  // counts/lx を求める
  float amplify = (atime / 546.0) * again;
  float cpl_r  = 11.2 * amplify;
  float cpl_g  = 8.3  * amplify;
  float cpl_b  = 4.4  * amplify;
  float cpl_ir = 3.0  * amplify;
  // lx を求める
  ColorLux result = {
    (uint16_t)(adc_r  / cpl_r),
    (uint16_t)(adc_g  / cpl_g),
    (uint16_t)(adc_b  / cpl_b),
    (uint16_t)(adc_ir / cpl_ir)
  };
  return result;
}

ColorLux MU_S11059::GetLux() {
  ReadAdc();
  Reset();
  return CalcLux();
}
