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
    // ペリフェラルのAdvertiseイベントをViewModelに通知するためのSubject
    let peripheralAdvSubject = PassthroughSubject<BlePeripheralModel, Never>()
    // キャラクタリスティックのNotifyイベントをViewModelに通知するためのSubject
    let characteristicMsgNotifySubject = PassthroughSubject<BleCharacteristicMsgEntity, Never>()
    
    // MARK: ESP32 Ble UUID
    let service_uuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
    let characteristic_uuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8"
    
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
                // ペリフェラルのアドバタイズが有効
                found.advReceive(rssi: RSSI.doubleValue)
                peripheralAdvSubject.send(found)
            case .adLost:
                // アドバタイズロスト回復
                found.advReceive(rssi: RSSI.doubleValue)
                peripheralAdvSubject.send(found)
                print("ペリフェラル再受信")
            case .adConnectReq:
                // 接続要求状態であればスキャンを停止して接続する
                centralManager?.stopScan()
                found.connecting(peripheral: peripheral)
                centralManager?.connect(peripheral)
                print("ペリフェラル接続受付")
            default:
                break
            }
            
        } else {
            // リストに追加
            let blePeripheral = BlePeripheralModel(rssi: RSSI.doubleValue, peripheralUuid: peripheral.identifier.uuidString, peripheralName: peripheral.name)
            blePeripheralModels.append(blePeripheral)
            peripheralAdvSubject.send(blePeripheral)
            if let services = peripheral.services {
                print("ペリフェラル追加\(peripheral.name ?? "Unknown")" + String(RSSI.doubleValue) + String(services.count))
            } else {
                print("ペリフェラル追加\(peripheral.name ?? "Unknown")" + String(RSSI.doubleValue))
            }
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
                switch found.state {
                case .adConnecting:
                    peripheral.delegate = self
                    // どんなサービスでも探す
                    peripheral.discoverServices(nil)
                    found.connected()
                    print("ペリフェラルに接続しました")
                default:
                    break
                }
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("ペリフェラルに接続失敗しました")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("ペリフェラルへの接続が切断されました")
    }
    // バックグラウンド実行から復帰した際に呼ばれる
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState")
    }
    
    
    // 接続したペリフェラルのサービスが見つかった時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = blePeripheralModels.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
            if error == nil {
                // 指定したキャラクタリスティックへの接続を要求する
                switch found.state {
                case .connAct:
                    if let services = peripheral.services {
                        for service in services {
                            // あらかじめ指定したサービスが見つかった
                            if service.uuid == CBUUID(string: service_uuid) {
                                print("サービス発見。キャラクラリスティックへ接続します。")
                                peripheral.discoverCharacteristics([CBUUID(string: characteristic_uuid)], for: service)
                            }
                        }
                    }
                    
                default:
                    break
                }
                
            } else {
                // ステータスを変更する
                // found.
                centralManager?.cancelPeripheralConnection(peripheral)
                
            }
        }
    }
    
    // 指定したキャラクタリスティックが見つかった時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = blePeripheralModels.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
            if error == nil {
                // 指定したキャラクタリスティックへの接続を要求する
                switch found.state {
                case .connAct:
                    if let characteristics = service.characteristics {
                        for characteristic in characteristics {
                            // あらかじめ指定したキャラクタリスティックが見つかった
                            if characteristic.uuid == CBUUID(string: characteristic_uuid) {
                                print("キャラクタリスティック発見!")
                                //Notificationを受け取るよっていうハンドラ
                                peripheral.setNotifyValue(true, for: characteristic)
                            }
                        }
                    }
                    
                default:
                    break
                }
                
            } else {
                // ステータスを変更する
                // found.
                centralManager?.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    // ペリフェラルからnotify通知があった時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = blePeripheralModels.first(where: { return $0.peripheralUuid == peripheral.identifier.uuidString }) {
            if error == nil {
                // 指定したキャラクタリスティックへの接続を要求する
                switch found.state {
                case .connAct:
                    // あらかじめ指定したキャラクタリスティックが見つかった
                    if characteristic.uuid == CBUUID(string: characteristic_uuid) {
                        guard let data = characteristic.value else {
                            return
                        }
                        characteristicMsgNotifySubject.send(
                            BleCharacteristicMsgEntity(peripheralUuid: peripheral.identifier.uuidString,
                                                       serviceUuid: characteristic.service!.uuid.uuidString,
                                                       characteristicUuid: characteristic.uuid.uuidString,
                                                       characteristicData: String(data: data, encoding: .ascii)!)
                        )
                    }
                default:
                    break
                }
                
            } else {
                // ステータスを変更する
                // found.
                centralManager?.cancelPeripheralConnection(peripheral)
                
            }
        }
    
    }
}
