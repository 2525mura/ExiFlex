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
    private var cancellables: [AnyCancellable] = []
    
    init() {
        self.bleService = BleService()
        bind()
    }
    
    // BleServiceからのBleペリフェラル更新通知を受け付ける処理
    func bind() {
        // BlePeripheralModelが更新されたら通知されるパイプライン処理の実装
        let peripheralAdvSubscriber = bleService.peripheralSubject.sink(receiveValue: { peripheral in
            // rssiの範囲は-100 〜 -30
            var blePower = Int(ceil((peripheral.rssi + 100.0) / 17.5))
            if blePower < 0 {blePower = 0}
            if blePower > 4 {blePower = 4}
            let rssi = Int(peripheral.rssi)
            // 既にペリフェラルが検出済みリストに登録されているかチェック
            if let found = self.devices.first(where: { return $0.peripheralUuid == peripheral.peripheralUuid }) {
                found.blePower = blePower
                found.rssi = rssi
                found.state = peripheral.state
            } else {
                self.devices.append(
                    PeripheralAdvViewModel(peripheralUuid: peripheral.peripheralUuid,
                                           peripheralName: peripheral.peripheralName,
                                           blePower: blePower,
                                           rssi: rssi,
                                           bleService: self.bleService)
                )
            }
        })
        
        // BleCharacteristicMsgEntityが生成されたら通知されるパイプライン処理の実装
        let characteristicMsgSubscriber = bleService.characteristicMsgNotifySubject.sink(receiveValue: { characteristicMsg in
            if let found = self.devices.first(where: { return $0.peripheralUuid == characteristicMsg.peripheralUuid }) {
                found.connViewModel.shutterCount+=1
            }
        })
        
        cancellables += [
            peripheralAdvSubscriber,
            characteristicMsgSubscriber
        ]
        
    }
    
    // ペリフェラルをタップした時に呼ばれる関数
    func connectDevice(device: PeripheralAdvViewModel) {
        bleService.connectPeripheral(peripheralUuid: device.peripheralUuid)
        if let found = devices.first(where: { return $0.peripheralUuid == device.peripheralUuid }) {
 
        }
    }
    
    // < をタップした時に呼ばれる関数
    func disConnectDevice(device: PeripheralAdvViewModel) {
        bleService.disConnectPeripheral(peripheralUuid: device.peripheralUuid)
        if let found = devices.first(where: { return $0.peripheralUuid == device.peripheralUuid }) {

        }
    }
    
}
