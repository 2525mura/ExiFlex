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
    var blePeripheralModels: [BlePeripheralModel] = []
    var peripheralConnect: CBPeripheral?
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
    
    func advHealthCheck() {
        // ペリフェラルのヘルスチェックを行う
        for bleModel in blePeripheralModels {
            let isStatusChanged = bleModel.healthCheck()
            if isStatusChanged && bleModel.state == .adLost {
                peripheralAdvSubject.send(bleModel)
                print("ペリフェラル消失")
            }
        }
    }
    
    // ペリフェラルのアドバタイズを受信
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = blePeripheralModels.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
            // RSSIと最終アドバタイズ受信日時を更新

            switch found.state {
            case .adAct:
                found.advReceive(rssi: RSSI.doubleValue)
                peripheralAdvSubject.send(found)
                print("ペリフェラル延長")
            case .adLost:
                found.advReceive(rssi: RSSI.doubleValue)
                peripheralAdvSubject.send(found)
                print("ペリフェラル再受信")
            case .adConnectReq:
                // 接続要求状態であればスキャンを停止して接続する
                peripheralConnect = peripheral
                centralManager?.stopScan()
                centralManager?.connect(peripheral)
                found.connecting()
                print("ペリフェラル接続受付")
            default:
                break
            }
            
        } else {
            // リストに追加
            let blePeripheral = BlePeripheralModel(rssi: RSSI.doubleValue, peripheralUuid: peripheral.identifier.uuidString, peripheralName: peripheral.name)
            blePeripheralModels.append(blePeripheral)
            peripheralAdvSubject.send(blePeripheral)
            print("ペリフェラル追加\(peripheral.name ?? "Unknown" + String(RSSI.doubleValue))")
        }
        
        advHealthCheck()
    }
    
    // ViewModelから指定したペリフェラルに接続するための関数
    func connectPeripheral(peripheralUuid: String) {
        if let found = blePeripheralModels.first(where: { return $0.peripheralUuid == peripheralUuid }) {
            print("ペリフェラル接続要求")
            found.connectReq()
        }
    }
    
    // ペリフェラルに接続成功したら呼び出される
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            // 検出済みリストに登録されているものかをチェック
            if let found = blePeripheralModels.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
                peripheral.delegate = self
                // どんなサービスでも探す
                peripheral.discoverServices(nil)
                found.connected()
                print("ペリフェラルに接続しました")
            }
        }
    }
    
    
}
