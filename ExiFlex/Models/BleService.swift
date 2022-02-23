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
                self.peripheralConnect = peripheral
                centralManager?.stopScan()
                found.connecting()
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
    // 指定したキャラクタリスティックのスキャンを要求する
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let periphName = peripheral.name ?? peripheral.identifier.uuidString
        print("サービス発見！" + periphName)
        if error == nil{
            for service in peripheral.services!{
            //    if service.uuid.uuidString.lowercased() == SERVICE_UUID.uuidString.lowercased() && !deviceList.contains(periphName){
                    peripheral.discoverCharacteristics([CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")], for: service)
                    print("ペリフェラル：" + periphName + "サービス" + service.uuid.uuidString.lowercased())
                    // BLE無線機個体に存在するサービスを一つずつビューに投入していく
                
                /*
                    BluetoothManagerDelegate?.DeviceDidDiscoverd(deviceName: periphName, deviceIdentifier: peripheral.identifier.uuidString)
                }
                 */
            }
        }
        
    }
    
}
