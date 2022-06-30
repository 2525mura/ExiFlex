//
//  Cie1931xyViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/06/28.
//

import Foundation
import UIKit

class Cie1931xyViewModel: ObservableObject {

    private let chartOrigin: CGPoint
    private let chartUnitScale: CGPoint
    private let cursorSize: Double
    private let chartImage: UIImage
    private var cursorImage: UIImage
    @Published var plotImage: UIImage

    init(chartImageName: String = "cie1931xy",
         chartOrigin: CGPoint = CGPoint(x: 135, y: 1033),
         chartUnitScale: CGPoint = CGPoint(x: 1184, y: 1184),
         cursorSize: Double = 10.0) {
        // chartImageName: チャート画像名
        // chartOrigin: CGPoint(チャート画像の原点ピクセル座標x, チャート画像の原点ピクセル座標y)
        // chartUnitScale: CGSize(xが1変化した場合の増加ピクセル数, yが1変化した場合の増加ピクセル数)
        self.chartOrigin = chartOrigin
        self.chartUnitScale = chartUnitScale
        self.cursorSize = cursorSize
        self.chartImage = UIImage(named: chartImageName)!
        self.cursorImage = UIImage()
        self.plotImage = UIImage()
        plot(chromaticity: CGPoint(x: 0.0, y: 0.0))
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

}
