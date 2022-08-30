//
//  CameraControlViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/05/09.
//

import Foundation
import Combine
import CoreData

final class CameraControlViewModel: ObservableObject {

    private let bleService: BleService
    private var cancellables: [AnyCancellable] = []
    // 画面部品の状態変数
    var isoValue: String = "100"
    var fValue: String = "2.8"
    var ssValue: String = "125"
    // Picker選択値から計算されたEV値
    var evValue: Double = 0
    // LUXセンサーから測定されたLV値
    var lvValue: Double = 0
    // LV - EV
    @Published var dEv: Double = 0
    private(set) var viewContext: NSManagedObjectContext?
    @Published private(set) var selectedRoll: Roll?
    @Published var lastId: UUID = UUID()
    @Published var isFilmLoaded: Bool
    
    init(bleService: BleService) {
        self.bleService = bleService
        self.bleService.addCharacteristicUuid(uuid: "beb5483e-36e1-4688-b7f5-ea07361b26a8", alias: "shutter")
        self.bleService.addCharacteristicUuid(uuid: "16cf81e3-0212-58b9-0380-0dbc6b54c51d", alias: "lux")
        self.isFilmLoaded = false
        bind()
    }
    
    // BleServiceからのキャラクタリスティック受信を受け付ける処理
    func bind() {
        // BleCharacteristicMsgEntityが生成されたら通知されるパイプライン処理の実装
        let characteristicMsgSubscriber = bleService.characteristicSharedPublisher.sink(receiveValue: { characteristicMsg in
            if characteristicMsg.characteristicAlias == "shutter" && self.isFilmLoaded {
                if let context = self.viewContext {
                    let takeMeta = self.selectedRoll!.take(viewContext: context, isoValue: self.isoValue, fValue: self.fValue, ssValue: self.ssValue)
                    self.lastId = takeMeta.id!
                }
            } else if characteristicMsg.characteristicAlias == "lux" {
                // LUX -> LV計算
                self.onChangeLv(recvStr: characteristicMsg.characteristicData)
            }
        })
        
        cancellables += [
            characteristicMsgSubscriber
        ]
    }
    
    func onChangeEv(isoValue: String, fValue: String, ssValue: String) {
        self.isoValue = isoValue
        self.fValue = fValue
        self.ssValue = ssValue
        let isoValueDouble = Double(self.isoValue)!
        let fValueDouble = Double(self.fValue)!
        let ssValueDouble = Double(self.ssValue)!
        let isoFix = log2(isoValueDouble / 100.0)
        self.evValue = 2 * log2(fValueDouble) + log2(ssValueDouble) - isoFix
        self.dEv = lvValue - evValue
    }
    
    func onChangeLv(recvStr: String) {
        if recvStr == "LUX:0" {
            return
        }
        let doubleLux = Double(recvStr.split(separator: ":")[1])!
        self.lvValue = log2(doubleLux / 2.5)
        self.dEv = lvValue - evValue
    }
    
    func setFilm(viewContext: NSManagedObjectContext, selectedRoll: Roll) {
        self.viewContext = viewContext
        self.selectedRoll = selectedRoll
        self.isFilmLoaded = true
        if let lastTakeMeta = self.selectedRoll!.takeMetasList.last {
            // 見つかったコマがリーダーでない場合
            if !lastTakeMeta.isLeader {
                // set後1秒後にフィルムの最後をアニメーション表示する
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.lastId = lastTakeMeta.id!
                }
            }
        }
    }
    
    func ejectFilm() {
        if let firstTakeMeta = self.selectedRoll!.takeMetasList.first {
            self.lastId = firstTakeMeta.id!
        }
        
        if let lastTakeMeta = self.selectedRoll!.takeMetasList.last {
            // 見つかったコマがリーダーでない場合
            if !lastTakeMeta.isLeader {
                // アニメーションが終わるのを待ってからeject状態にする
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isFilmLoaded = false
                }
            } else {
                self.isFilmLoaded = false
            }
        } else {
            self.isFilmLoaded = false
        }
    }
    
    func addFilm(viewContext: NSManagedObjectContext) {
        let newRoll = Roll(context: viewContext)
        newRoll.id = UUID()
        newRoll.rollName = "フィルム"
        newRoll.takeCount = 0
        newRoll.createdAt = Date()
        // 保存
        try? viewContext.save()
        newRoll.addLeader(viewContext: viewContext)
    }
    
}

