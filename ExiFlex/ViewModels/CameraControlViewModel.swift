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
    @Published var isoValue: String = "100"
    @Published var fValue: String = "2.8"
    @Published var ssValue: String = "125"
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
                    // 仮の処理
                    print(self.calcLv(recvStr: characteristicMsg.characteristicData))
                    
                }
            }
        })
        
        cancellables += [
            characteristicMsgSubscriber
        ]
    }
    
    func calcLv(recvStr: String) -> Double {
        let doubleLux = Double(recvStr.suffix(2))!
        return log2(doubleLux / 2.5)
    }
    
    func startAdvertiseScan() {
        self.peripheralListVm.bind()
        self.bleService.flushPeripherals()
        self.bleService.startAdvertiseScan()
    }
    
}

