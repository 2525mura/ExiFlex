//
//  PeripheralListViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation
import Combine


final class PeripheralListViewModel: ObservableObject {

    let bleService: BleService
    @Published private(set) var devices: [PeripheralAdvViewModel] = []
    @Published private(set) var connViewModel: PeripheralConnViewModel
    private var cancellables: [AnyCancellable] = []
    
    init() {
        self.bleService = BleService()
        self.connViewModel = PeripheralConnViewModel(bleService: self.bleService)
        bind()
    }
    
    // BleServiceからのBleペリフェラル更新通知を受け付ける処理
    func bind() {
        let peripheralAdvSubscriber = bleService.peripheralAdvSubject.sink(receiveValue: { peripheral in
            // rssiの範囲は-100 〜 -30
            var blePower = Int(ceil((peripheral.rssi + 100.0) / 17.5))
            if blePower < 0 {blePower = 0}
            if blePower > 4 {blePower = 4}
            let rssi = Int(peripheral.rssi)
            // 既にペリフェラルが検出済みリストに登録されているかチェック
            if let foundId = self.devices.firstIndex(where: { return $0.peripheralUuid == peripheral.peripheralUuid }) {
                self.devices[foundId].blePower = blePower
                self.devices[foundId].rssi = rssi
                self.devices[foundId].state = peripheral.state
            } else {
                self.devices.append(
                    PeripheralAdvViewModel(peripheralUuid: peripheral.peripheralUuid,
                                           peripheralName: peripheral.peripheralName,
                                           blePower: blePower,
                                           rssi: rssi)
                )
            }
        })
        cancellables += [
            peripheralAdvSubscriber
        ]
        
    }
    
    // ペリフェラルをタップした時に呼ばれる関数
    func connectDevice(device: PeripheralAdvViewModel) {
        bleService.connectPeripheral(peripheralUuid: device.peripheralUuid)
        if let found = devices.first(where: { return $0.peripheralUuid == device.peripheralUuid }) {
        }
    }
}
