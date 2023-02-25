//
//  MU_S11059.h
//  MU_S11059 Driver
//
//  Created by 村井慎太郎 on 2022/06/26.
//

#include "Arduino.h"
#include <Wire.h>

struct ColorLux {
  uint16_t lux_r;
  uint16_t lux_g;
  uint16_t lux_b;
  uint16_t lux_ir;
};

class MU_S11059 {
  public:
    MU_S11059();
    void Reset();
    void SetGain(uint8_t ag);
    void SetIntegralTime(uint8_t at, uint16_t at_coef);
    ColorLux GetLux();

    //S11059 Command Parameter Set;
    static const uint8_t S11059_GAIN_HIGH       = 0x08;
    static const uint8_t S11059_GAIN_LOW        = 0x00;
    static const uint8_t S11059_INTTIME_175     = 0x00;
    static const uint8_t S11059_INTTIME_2800    = 0x01;
    static const uint8_t S11059_INTTIME_44800   = 0x02;
    static const uint8_t S11059_INTTIME_358400  = 0x03;

  private:
    void ReadAdc();
    void WriteReg(uint8_t reg, uint8_t dat);
    ColorLux CalcLux();

    //used to calculate Lux
    uint16_t adc_r, adc_g, adc_b, adc_ir;
    float atime, again;

    //used to settings
    uint8_t atime_bit, again_bit;
    uint16_t atime_coefficient;

    //S11059 Register Set;
    const uint8_t S11059_ADR      = 0x2A;
    const uint8_t S11059_COMMAND  = 0x00;
    const uint8_t S11059_TIMINGH  = 0x01;
    const uint8_t S11059_TIMINGL  = 0x02;
    const uint8_t S11059_RDATAH   = 0x03;
    const uint8_t S11059_RDATAL   = 0x04;
    const uint8_t S11059_GDATAH   = 0x05;
    const uint8_t S11059_GDATAL   = 0x06;
    const uint8_t S11059_BDATAH   = 0x07;
    const uint8_t S11059_BDATAL   = 0x08;
    const uint8_t S11059_IRDATAH  = 0x09;
    const uint8_t S11059_IRDATAL  = 0x0A;

    //S11059 Command Parameter Set;
    static const uint8_t S11059_ADC_RESET       = 0x80;
    static const uint8_t S11059_SLEEP           = 0x40;
    static const uint8_t S11059_MODE_MANU       = 0x04;
};
