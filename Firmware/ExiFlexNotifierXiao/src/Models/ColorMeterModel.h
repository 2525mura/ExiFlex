//
//  ColorMeterModel.h
//  Exiflex color meter model
//
//  Created by 村井慎太郎 on 2023/02/25.
//

#include "Arduino.h"
#include "../Infrastructures/MU_S11059.h"

class ColorMeterModel {
    public:
        ColorMeterModel();
        void initColorSensor();
        void measureColor(float* r, float* g, float* b, float* ir);

    private:
        // Colorセンサー
        MU_S11059 S11059;
};
