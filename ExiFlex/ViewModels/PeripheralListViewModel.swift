//
//  PeripheralListViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation
import Combine

final class PeripheralListViewModel: ObservableObject {

    private let bleService: BleService
    @Published private(set) var peripherals: [PeripheralAdvViewModel] = []
    private var cancellables: [AnyCancellable] = []
    
    init(bleService: BleService) {
        self.bleService = bleService
    }
    
    // BleServiceからのアドバタイズ更新通知を受け付ける処理
    func bind() {
        // BlePeripheralModelが更新されたら通知されるパイプライン処理の実装
        let peripheralAdvSubscriber = bleService.peripheralSubject.sink(receiveValue: { peripheral in
            // rssiの範囲は-100 〜 -30
            var blePower = Int(ceil((peripheral.rssi + 100.0) / 17.5))
            if blePower < 0 {blePower = 0}
            if blePower > 4 {blePower = 4}
            let rssi = Int(peripheral.rssi)
            // 既にペリフェラルが検出済みリストに登録されているかチェック
            if let found = self.peripherals.first(where: { return $0.peripheralUuid == peripheral.peripheralUuid.uuidString }) {
                found.blePower = blePower
                found.rssi = rssi
                found.state = peripheral.state
            } else {
                self.peripherals.append(
                    PeripheralAdvViewModel(peripheralUuid: peripheral.peripheralUuid.uuidString,
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
    
    // ペリフェラル選択のキャンセルボタンを押した時に呼ばれる関数
    func stopAdvertiseScan() {
        self.bleService.stopAdvertiseScan()
    }
    
    // ペリフェラルをタップした時に呼ばれる関数
    func connectPeripheral(peripheral: PeripheralAdvViewModel) {
        self.bleService.connectPeripheral(peripheralUuid: peripheral.peripheralUuid)
    }
    
    // 全ての接続済みペリフェラルを切断するための関数
    func disConnectPeripheralAll() {
        self.bleService.disConnectPeripheralAll()
    }
    
    func removeAllPeripherals() {
        // ここでパイプラインを止める
        cancellables[0].cancel()
        self.peripherals.removeAll()
    }
    
    
}
