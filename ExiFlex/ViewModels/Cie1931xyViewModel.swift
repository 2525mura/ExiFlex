//
//  Cie1931xyViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/06/28.
//

import Foundation
import Combine
import UIKit

class Cie1931xyViewModel: ObservableObject {

    private let bleCentral: BleCentral
    private var cancellables: [AnyCancellable] = []
    private let chartOrigin: CGPoint
    private let chartUnitScale: CGPoint
    private let cursorSize: Double
    private let chartImage: UIImage
    private var cursorImage: UIImage
    private let tcs3430Utility: Tcs3430Utility
    @Published var plotImage: UIImage
    @Published var luxMonitor: Double
    @Published var cieX: Double
    @Published var cieY: Double
    @Published var cieZ: Double
    @Published var cieIR1: Double
    @Published var colorTemp: Double

    init(bleCentral: BleCentral,
         chartImageName: String = "cie1931xy",
         chartOrigin: CGPoint = CGPoint(x: 135, y: 1033),
         chartUnitScale: CGPoint = CGPoint(x: 1184, y: 1184),
         cursorSize: Double = 10.0) {
        // chartImageName: チャート画像名
        // chartOrigin: CGPoint(チャート画像の原点ピクセル座標x, チャート画像の原点ピクセル座標y)
        // chartUnitScale: CGSize(xが1変化した場合の増加ピクセル数, yが1変化した場合の増加ピクセル数)
        self.bleCentral = bleCentral
        self.chartOrigin = chartOrigin
        self.chartUnitScale = chartUnitScale
        self.cursorSize = cursorSize
        self.chartImage = UIImage(named: chartImageName)!
        self.cursorImage = UIImage()
        self.tcs3430Utility = Tcs3430Utility()
        self.plotImage = UIImage()
        self.luxMonitor = 0.0
        self.cieX = 0.0
        self.cieY = 0.0
        self.cieZ = 0.0
        self.cieIR1 = 0.0
        self.colorTemp = 0.0
        plot(chromaticity: CGPoint(x: 0.0, y: 0.0))
        bind()
    }

    // 2つのUIImageを1つのUIImageに合成
    private func plot(chromaticity: CGPoint) {
        let cursorPoint = CGPoint(x: (self.chartOrigin.x + self.chartUnitScale.x * chromaticity.x) / self.chartImage.scale,
                                  y: (self.chartOrigin.y - self.chartUnitScale.y * chromaticity.y) / self.chartImage.scale)
        // CAShapeLayerと使ってカーソルを描画
        let caLayer   = CAShapeLayer()
        let size      = self.chartImage.size
        caLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        caLayer.path  = UIBezierPath(ovalIn:
                                        CGRect.init(x: cursorPoint.x - self.cursorSize / 2,
                                                    y: cursorPoint.y - self.cursorSize / 2,
                                                    width: self.cursorSize,
                                                    height: self.cursorSize)).cgPath
        caLayer.fillColor   = UIColor.clear.cgColor
        caLayer.strokeColor = UIColor.black.cgColor

        // カーソルをUIImageにレンダリング
        UIGraphicsBeginImageContextWithOptions(caLayer.frame.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        caLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.cursorImage = image!

        // CIE1931xyチャートのUIImageとレンダリングされたカーソルのUIImageを合成
        UIGraphicsBeginImageContext(CGSize(width: size.width, height: size.height))
        self.chartImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.cursorImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.plotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    // BleCentralからのキャラクタリスティック受信を受け付ける処理
    func bind() {
        // characteristicLux subscribe process
        let luxSubscriber = bleCentral.bleProfile.bleServiceExpose.onRecvLuxPublisher.sink(receiveValue: { payload in
            self.luxMonitor = Double(payload.lux)
        })
        
        // characteristicLux subscribe process
        let rgbSubscriber = bleCentral.bleProfile.bleServiceExpose.onRecvRGBPublisher.sink(receiveValue: { payload in
            self.onChangeRGB(rgb: payload)
        })
        
        cancellables += [
            luxSubscriber,
            rgbSubscriber
        ]
    }
    
    func onChangeRGB(rgb: CharacteristicRGB) {
        let ir = Double(rgb.ir)
        // Estimate XYZ from RGB
        let tristimulus = tcs3430Utility.getTristimulus(
            X: Double(rgb.r),
            Y: Double(rgb.g),
            Z: Double(rgb.b),
            IR: ir
        )
        // Set parameter to View
        self.cieX = tristimulus.X
        self.cieY = tristimulus.Y
        self.cieZ = tristimulus.Z
        self.cieIR1 = ir
        self.colorTemp = tristimulus.colorTemp
        plot(chromaticity: CGPoint(x: tristimulus.x, y: tristimulus.y))
    }
    
}
