//
//  BlePeripheralModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/14.
//

import Foundation
import CoreBluetooth
import Combine

// BLEペリフェラルの状態を管理するためのモデル。キーはperipheralUuid。
class BlePeripheralModel {
    
    private (set) var rssi : Double
    private (set) var peripheralUuid: String
    private (set) var peripheralName: String?
    private (set) var state: BlePeripheralState     // BLEペリフェラル状態
    private var lastAdvRecvDate: Date               // Advertise最終受信日時
    private var peripheralConnect: CBPeripheral?

    init(rssi: Double, peripheralUuid: String, peripheralName: String?) {
        self.rssi = rssi
        self.peripheralUuid = peripheralUuid
        self.peripheralName = peripheralName
        self.state = .adAct
        self.lastAdvRecvDate = Date()
        self.peripheralConnect = nil
    }
    
    func advReceive(rssi: Double, notifier: PassthroughSubject<BlePeripheralModel, Never>?) {
        // RSSIが変化した、または、アドバタイズ有効でない状態から復帰した場合
        if (self.rssi != rssi) || (self.state != .adAct) {
            self.rssi = rssi
            self.state = .adAct
            self.lastAdvRecvDate = Date()
            notifier?.send(self)
        }
    }
    
    // ViewModelからタイマー実行される。stateに変化があったらtrue を返す
    func advHealthCheck(notifier: PassthroughSubject<BlePeripheralModel, Never>?) {
        switch self.state {
        case .adAct:
            // 最後にアドバタイズされてから5秒以上経っていたら、アドバタイズ有効から無功に切り替える
            if Date().timeIntervalSince(self.lastAdvRecvDate) > 5 {
                self.rssi = -100
                self.state = .adLost
                notifier?.send(self)
            }
        default:
            break
            
        }
    }
    
    func connectReq() {
        self.state = .adConnectReq
    }
    
    func connecting(peripheral: CBPeripheral) {
        self.peripheralConnect = peripheral
        self.state = .adConnecting
    }
    
    func connected() {
        self.state = .connAct
    }
    
    func disConnectReq() -> CBPeripheral? {
        self.state = .connDisconnecting
        return self.peripheralConnect
    }
    
    func disConnected() {
        self.state = .connDisconnected
        self.peripheralConnect = nil
    }
    
}
