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
    // 画面部品の状態変数
    @Published var isoValue: String = "100"
    @Published var fValue: String = "2.8"
    @Published var ssValue: String = "125"
    @Published private(set) var takeMetas: [TakeMetaViewModel] = []
    @Published var lastId: UUID = UUID()
    
    init() {
        self.bleService = BleService()
        peripheralListVm = PeripheralListViewModel(bleService: bleService)
        bind()
    }
    
    // BleServiceからのキャラクタリスティック受信を受け付ける処理
    func bind() {
        // BleCharacteristicMsgEntityが生成されたら通知されるパイプライン処理の実装
        let characteristicMsgSubscriber = bleService.characteristicMsgNotifySubject.sink(receiveValue: { characteristicMsg in
            if characteristicMsg.characteristicData=="SHUTTER" {
                let takeMetaViewModel = TakeMetaViewModel(isoValue: self.isoValue, fValue: self.fValue, ssValue: self.ssValue)
                self.takeMetas.append(takeMetaViewModel)
                self.lastId = takeMetaViewModel.id
            }
        })
        
        cancellables += [
            characteristicMsgSubscriber
        ]
    }
    
    func startAdvertiseScan() {
        self.peripheralListVm.bind()
        self.bleService.flushPeripherals()
        self.bleService.startAdvertiseScan()
    }
    
}

