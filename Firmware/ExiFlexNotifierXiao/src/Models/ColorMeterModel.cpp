//
//  ColorMeterModel.cpp
//  Exiflex color meter model
//
//  Created by 村井慎太郎 on 2023/02/25.
//

#include "ColorMeterModel.h"

ColorMeterModel::ColorMeterModel() {
}

void ColorMeterModel::initColorSensor() {
    // Colorセンサー初期化
    S11059.SetIntegralTime(MU_S11059::S11059_INTTIME_175, 285);
}

void ColorMeterModel::measureColor(float* r, float* g, float* b, float* ir) {
    //TSL2572.GetLux16()で照度を取得
    ColorLux colorLux = S11059.GetLux();
    *r = colorLux.lux_r;
    *g = colorLux.lux_g;
    *b = colorLux.lux_b;
    *ir = colorLux.lux_ir;
}
