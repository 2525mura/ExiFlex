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
    
    init() {
        self.bleService = BleService()
        peripheralListVm = PeripheralListViewModel(bleService: bleService)
        bind()
    }
    
    // BleServiceからのキャラクタリスティック受信を受け付ける処理
    func bind() {
        // BleCharacteristicMsgEntityが生成されたら通知されるパイプライン処理の実装
        let characteristicMsgSubscriber = bleService.characteristicMsgNotifySubject.sink(receiveValue: { characteristicMsg in
            //if let found = self.devices.first(where: { return $0.peripheralUuid == characteristicMsg.peripheralUuid }) {
                //found.connViewModel.shutterCount+=1
            //}
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

