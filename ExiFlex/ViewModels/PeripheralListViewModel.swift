//
//  PeripheralListViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation
import CoreBluetooth

final class PeripheralListViewModel: ObservableObject, BleCentralDelegate {

    private let bleService: BleService
    @Published private(set) var peripherals: [PeripheralAdvViewModel] = []
    
    init(bleService: BleService) {
        self.bleService = bleService
    }
    
    // BleServiceからのアドバタイズ更新通知を受け付ける処理
    func bind() {
        bleService.delegate = self
    }
    
    func peripheralDidDiscover(uuid: UUID, peripheral: CBPeripheral, rssi: Double) {
        // rssiの範囲は-100 〜 -30
        var blePower = Int(ceil((rssi + 100.0) / 17.5))
        if blePower < 0 {blePower = 0}
        if blePower > 4 {blePower = 4}
        let rssi = Int(rssi)
        // ペリフェラル情報を追加する
        self.peripherals.append(
            PeripheralAdvViewModel(peripheralUuid: peripheral.identifier.uuidString,
                                   peripheralName: peripheral.name,
                                   blePower: blePower,
                                   rssi: rssi)
        )
    }
    
    func peripheralDidUpdate(uuid: UUID, peripheral: CBPeripheral, rssi: Double) {
        // rssiの範囲は-100 〜 -30
        var blePower = Int(ceil((rssi + 100.0) / 17.5))
        if blePower < 0 {blePower = 0}
        if blePower > 4 {blePower = 4}
        let rssi = Int(rssi)
        // ペリフェラルを更新する
        if let vmPeripheral = peripherals.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
            vmPeripheral.blePower = blePower
            vmPeripheral.rssi = rssi
            vmPeripheral.state = .adAct
        }
    }
    
    func peripheralDidDelete(uuid: UUID) {
        if let index = peripherals.firstIndex(where: { return $0.peripheralUuid == uuid.uuidString }) {
            peripherals.remove(at: index)
        }
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
        // ここでdelegateを止める
        self.bleService.delegate = nil
        self.peripherals.removeAll()
    }
    
    
}
