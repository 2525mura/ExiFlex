//
//  Tcs3430Utility.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/07.
//

import Foundation

public class Tcs3430Utility {
    var CalibrationMat: Matrix
    
    //コンストラクタ
    public init() {
        // AGain=4, 3M 3635-70透過光でキャリブレーション実施
        self.CalibrationMat = Matrix(data:[
            [3.90578847457348 , 2.0874921015221 , -0.155381539116864, 0],
            [1.93484057081786 , 3.70010177669314, 1.70093033904747  , 0],
            [-11.3871912750659, 13.8675334913164, 12.6587608054979  , 0]])
    }
    
    private func calibrate(input: Matrix) -> Matrix {
        return self.CalibrationMat * input        
    }
    
    private func getColorTemp(x: Double, y: Double) -> Double {
        // x, yからCCTを計算（TCS3430 Calculating Color Temperature and Illuminance (DN 25)）
        let n = (x - 0.3320) / (0.1858 - y)
        let cct = 449 * pow(n, 3) + 3525 * pow(n, 2) + 6823.3 * n + 5520.33
        return cct
    }
    
    func getTristimulus(X: Double, Y: Double, Z: Double, IR: Double) -> TristimulusEntity {
        let raw = Matrix(data:[[X], [Y], [Z], [IR]])
        // キャリブレーションおよびパラメータの計算
        let calib = calibrate(input: raw)
        let sumXYZ = calib.data[0][0] + calib.data[1][0] + calib.data[2][0]
        let x = calib.data[0][0] / sumXYZ
        let y = calib.data[1][0] / sumXYZ
        // 計算値をセット
        let tristimulus = TristimulusEntity(
            X: calib.data[0][0],
            Y: calib.data[1][0],
            Z: calib.data[2][0],
            x: x,
            y: y,
            colorTemp: getColorTemp(x: x, y: y)
        )
        return tristimulus
    }
    
}
