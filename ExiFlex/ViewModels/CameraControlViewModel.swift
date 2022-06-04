//
//  CameraControlViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/05/09.
//

import Foundation
import Combine

final class CameraControlViewModel: ObservableObject {

    let bleService: BleService
    var peripheralListVm: PeripheralListViewModel
    private var cancellables: [AnyCancellable] = []
    let characteristicUuids = ["shutter": "beb5483e-36e1-4688-b7f5-ea07361b26a8", "lux": "16cf81e3-0212-58b9-0380-0dbc6b54c51d"]
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
    @Published private(set) var takeMetas: [TakeMetaViewModel] = []
    @Published var lastId: UUID = UUID()
    
    init() {
        self.bleService = BleService()
        self.bleService.setCharacteristicUuids(uuids: [String](self.characteristicUuids.values))
        peripheralListVm = PeripheralListViewModel(bleService: bleService)
        bind()
    }
    
    // BleServiceからのキャラクタリスティック受信を受け付ける処理
    func bind() {
        // BleCharacteristicMsgEntityが生成されたら通知されるパイプライン処理の実装
        let characteristicMsgSubscriber = bleService.characteristicMsgNotifySubject.sink(receiveValue: { characteristicMsg in
            if let characteristicTag = self.characteristicUuids.first(
                where: { $0.value.caseInsensitiveCompare(characteristicMsg.characteristicUuid) == .orderedSame }
            ) {
                if characteristicTag.key == "shutter" {
                    let takeMetaViewModel = TakeMetaViewModel(isoValue: self.isoValue, fValue: self.fValue, ssValue: self.ssValue)
                    self.takeMetas.append(takeMetaViewModel)
                    self.lastId = takeMetaViewModel.id
                } else if characteristicTag.key == "lux" {
                    // LUX -> LV計算
                    self.onChangeLv(recvStr: characteristicMsg.characteristicData)
                }
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
        let startIndex = recvStr.index(recvStr.startIndex, offsetBy: 4)
        let endIndex = recvStr.index(recvStr.endIndex, offsetBy: -1)
        let doubleLux = Double(recvStr[startIndex...endIndex])!
        self.lvValue = log2(doubleLux / 2.5)
        self.dEv = lvValue - evValue
        print("Lux:\(doubleLux), LV:\(String(format: "%.1f", self.lvValue)), dEV:\(String(format: "%.1f", self.dEv))")
    }
    
    func startAdvertiseScan() {
        self.peripheralListVm.bind()
        self.bleService.flushPeripherals()
        self.bleService.startAdvertiseScan()
    }
    
}

