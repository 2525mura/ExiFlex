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
    
    private var centralManager: CBCentralManager?
    private var blePeripheralModels: [CBUUID:BlePeripheralModel] = [:]
    private var advHealthCheckTimer: Timer?
    // ペリフェラルの状態変化イベントをViewModelに通知するためのSubject
    let peripheralSubject: PassthroughSubject<BlePeripheralModel, Never>
    // キャラクタリスティックのNotifyイベントをViewModelに通知するためのSubject
    private let characteristicMsgNotifySubject: PassthroughSubject<BleCharacteristicMsgEntity, Never>
    let characteristicSharedPublisher: Publishers.Share<AnyPublisher<BleCharacteristicMsgEntity, Never>>
    
    // MARK: ESP32 Ble UUID
    private let service_uuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
    private var characteristicUuids: [CBUUID] = []
    private var characteristicAliases: [CBUUID:String] = [:]
    
    // MARK: - Init
    // セントラルマネージャを起動する
    override init() {
        self.peripheralSubject = PassthroughSubject<BlePeripheralModel, Never>()
        self.characteristicMsgNotifySubject = PassthroughSubject<BleCharacteristicMsgEntity, Never>()
        self.characteristicSharedPublisher = self.characteristicMsgNotifySubject.eraseToAnyPublisher().share()
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // 定期的に実行される
    @objc private func advHealthCheckFunc() {
        for hashElem in blePeripheralModels {
            let bleModel = hashElem.value
            let statusChanged = bleModel.advHealthCheck()
            if statusChanged {
                self.peripheralSubject.send(bleModel)
            }
        }
    }
    
    func addCharacteristicUuid(uuid: String, alias: String) {
        let cbUuid = CBUUID(string: uuid)
        self.characteristicUuids.append(cbUuid)
        self.characteristicAliases[cbUuid] = alias
    }
    // セントラルマネージャーが電源ONになったらペリフェラルのスキャンを開始する
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        // どんなサービスでもスキャン対象とする、アドバタイズを2回以上受信した場合も通知する
        case CBManagerState.poweredOn:
            break
        default:
            break
        }
    }
    
    
    func startAdvertiseScan() {
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        // 各ペリフェラルのアドバタイズ最終受信日時を監視するタイマー
        self.advHealthCheckTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.advHealthCheckFunc),
            userInfo: nil,
            repeats: true
        )
    }
    
    // PeripheralListView表示時にPeripheralModelを全て送信する関数
    func flushPeripherals() {
        for hashElem in blePeripheralModels {
            let bleModel = hashElem.value
            self.peripheralSubject.send(bleModel)
        }
    }
    
    func stopAdvertiseScan() {
        // ヘルスチェックタイマーを止めてからAdvertise scanを停止する
        self.advHealthCheckTimer?.invalidate()
        centralManager?.stopScan()
        // 接続要求または接続中または接続済みのペリフェラル以外を削除する
        for hashElem in blePeripheralModels {
            let bleModelUuid = hashElem.key
            let bleModel = hashElem.value
            if !(bleModel.state == .adConnectReq || bleModel.state == .adConnecting || bleModel.state == .connAct) {
                blePeripheralModels.removeValue(forKey: bleModelUuid)
            }
        }
    }
    
    // ペリフェラルのアドバタイズを受信
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = blePeripheralModels[CBUUID(string: peripheral.identifier.uuidString)] {
            // RSSIと最終アドバタイズ受信日時を更新
            switch found.state {
                // 直前のステータス
            case .adAct:
                // ペリフェラルのアドバタイズが有効
                let statusChanged = found.advReceive(rssi: RSSI.doubleValue)
                if statusChanged {
                    self.peripheralSubject.send(found)
                }
            case .adLost:
                // アドバタイズロスト回復
                let statusChanged = found.advReceive(rssi: RSSI.doubleValue)
                if statusChanged {
                    self.peripheralSubject.send(found)
                }
                print("ペリフェラル再受信")
            case .adConnectReq:
                // スキャン停止する
                stopAdvertiseScan()
                found.connecting(peripheral: peripheral)
                centralManager?.connect(peripheral)
                print("ペリフェラル接続受付")
            case .connDisconnected:
                // 切断後のアドバタイズ受信
                let statusChanged = found.advReceive(rssi: RSSI.doubleValue)
                if statusChanged {
                    self.peripheralSubject.send(found)
                }
                print("切断後のアドバタイズ受信")
            default:
                break
            }
            
        } else {
            // ハッシュテーブルになければペリフェラルを追加
            let newCBUuid = CBUUID(string: peripheral.identifier.uuidString)
            let blePeripheral = BlePeripheralModel(rssi: RSSI.doubleValue,
                                                   peripheralUuid: newCBUuid,
                                                   peripheralName: peripheral.name
            )
            self.peripheralSubject.send(blePeripheral)
            blePeripheralModels[newCBUuid] = blePeripheral
            if let services = peripheral.services {
                print("ペリフェラル追加\(peripheral.name ?? "Unknown")" + String(RSSI.doubleValue) + String(services.count))
            } else {
                print("ペリフェラル追加\(peripheral.name ?? "Unknown")" + String(RSSI.doubleValue))
            }
        }
    }
    
    // ViewModelから指定したペリフェラルに接続するための関数
    func connectPeripheral(peripheralUuid: String) {
        if let found = blePeripheralModels[CBUUID(string: peripheralUuid)] {
            print("ペリフェラル接続要求")
            found.connectReq()
        }
    }
    
    // ViewModelから指定したペリフェラルを切断するための関数
    func disConnectPeripheral(peripheralUuid: String) {
        if let found = blePeripheralModels[CBUUID(string: peripheralUuid)] {
            print("ペリフェラル切断要求")
            let peripheral = found.disConnectReq()
            centralManager?.cancelPeripheralConnection(peripheral!)
        }
    }
    
    // ViewModelから全てのペリフェラルを切断するための関数
    func disConnectPeripheralAll() {
        for hashElem in blePeripheralModels {
            let peripheralModel = hashElem.value
            if peripheralModel.state == .connAct {
                let peripheral = peripheralModel.disConnectReq()
                centralManager?.cancelPeripheralConnection(peripheral!)
            }
        }
    }
    
    // ペリフェラルに接続成功したら呼び出される
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            // 検出済みリストに登録されているものかをチェック
            if let found = blePeripheralModels[CBUUID(string: peripheral.identifier.uuidString)] {
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
        if let found = blePeripheralModels[CBUUID(string: peripheral.identifier.uuidString)] {
            found.disConnected()
            print("ペリフェラル切断済み")
        }
    }
    // バックグラウンド実行から復帰した際に呼ばれる
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState")
    }
    
    
    // 接続したペリフェラルのサービスが見つかった時に呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // 既にペリフェラルが検出済みリストに登録されているかチェック
        if let found = blePeripheralModels[CBUUID(string: peripheral.identifier.uuidString)] {
            if error == nil {
                // 指定したキャラクタリスティックへの接続を要求する
                switch found.state {
                case .connAct:
                    if let services = peripheral.services {
                        for service in services {
                            // あらかじめ指定したサービスが見つかった
                            if service.uuid == CBUUID(string: service_uuid) {
                                print("サービス発見。キャラクラリスティックへ接続します。")
                                peripheral.discoverCharacteristics(self.characteristicUuids, for: service)
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
        if let found = blePeripheralModels[CBUUID(string: peripheral.identifier.uuidString)] {
            if error == nil {
                // 指定したキャラクタリスティックへの接続を要求する
                switch found.state {
                case .connAct:
                    if let characteristics = service.characteristics {
                        for characteristic in characteristics {
                            // あらかじめ指定したキャラクタリスティックが見つかった
                            if self.characteristicUuids.contains(characteristic.uuid) {
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
        if let found = blePeripheralModels[CBUUID(string: peripheral.identifier.uuidString)] {
            if error == nil {
                // 指定したキャラクタリスティックへの接続を要求する
                switch found.state {
                case .connAct:
                    // あらかじめ指定したキャラクタリスティックが見つかった
                    if self.characteristicUuids.contains(characteristic.uuid) {
                        guard let data = characteristic.value else {
                            return
                        }
                        characteristicMsgNotifySubject.send(
                            BleCharacteristicMsgEntity(peripheralUuid: peripheral.identifier.uuidString,
                                                       serviceUuid: characteristic.service!.uuid.uuidString,
                                                       characteristicUuid: characteristic.uuid.uuidString,
                                                       characteristicAlias: self.characteristicAliases[characteristic.uuid]!,
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
