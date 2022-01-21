//
//  BleService.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/13.
//

import Foundation
import Combine
import CoreBluetooth


class BleService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager?
    var peripherals: [BlePeripheralModel] = []
    // ペリフェラルのアドバタイズイベントをViewModelに通知するためのSubject
    let peripheralAdvSubject = PassthroughSubject<BlePeripheralModel, Never>()
    
    // MARK: - Init
    // セントラルマネージャを起動する
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // セントラルマネージャーが電源ONになったらペリフェラルのスキャンを開始する
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        // どんなサービスでもスキャン対象とする、アドバタイズを2回以上受信した場合も通知する
        case CBManagerState.poweredOn:
            centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            break
        default:
            break
        }
    }
    
    // ペリフェラルのアドバタイズを受信
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = peripherals.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
            // RSSIと最終アドバタイズ受信日時を更新
            found.rssi = RSSI.doubleValue
            found.lastAdvRecvDate = Date()
            found.isLostAdv = false
            found.peripheral = peripheral
            peripheralAdvSubject.send(found)
            print("ペリフェラル延長")
        } else {
            // リストに追加
            let blePeripheral = BlePeripheralModel(peripheral: peripheral, rssi: RSSI.doubleValue)
            peripherals.append(blePeripheral)
            peripheralAdvSubject.send(blePeripheral)
            print("ペリフェラル追加\(peripheral.name ?? "Unknown" + String(RSSI.doubleValue))")
        }
        
        // deviceListの有効なものだけを残す
        for index in (0..<peripherals.count).reversed() {
            // 未接続でしばらくアドバタイズを受信していないペリフェラルに対して消失フラグを有効にする
            if (Date().timeIntervalSince(peripherals[index].lastAdvRecvDate) > 5 && !peripherals[index].isConnect) {
                peripherals[index].rssi = -100.0
                peripherals[index].isLostAdv = true
                peripheralAdvSubject.send(peripherals[index])
                print("ペリフェラル消失")
            }
        }
    }
    
    // ViewModelから指定したペリフェラルに接続するための関数
    func connectPeripheral(peripheralUuid: String) {
        if let found = peripherals.first(where: { return $0.peripheralUuid == peripheralUuid }) {
            centralManager?.stopScan()
            centralManager?.connect(found.peripheral)
        }
    }
    
    
    // ペリフェラルに接続成功したら呼び出される
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            // 検出済みリストに登録されているものかをチェック
            if let found = peripherals.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
                peripheral.delegate = self
                // どんなサービスでも探す
                peripheral.discoverServices(nil)
                found.isConnect = true
                print("ペリフェラルに接続しました")
            }
        }
    }
    
    
}
