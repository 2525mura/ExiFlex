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
    private var peripheralSubject: PassthroughSubject<BlePeripheralModel, Never>

    init(rssi: Double, peripheralUuid: String, peripheralName: String?, peripheralSubject: PassthroughSubject<BlePeripheralModel, Never>) {
        self.rssi = rssi
        self.peripheralUuid = peripheralUuid
        self.peripheralName = peripheralName
        self.state = .adAct
        self.lastAdvRecvDate = Date()
        self.peripheralConnect = nil
        self.peripheralSubject = peripheralSubject
        self.peripheralSubject.send(self)
    }
    
    func advReceive(rssi: Double) {
        if (self.rssi != rssi) || (self.state != .adAct) {
            self.rssi = rssi
            self.state = .adAct
            self.lastAdvRecvDate = Date()
            self.peripheralSubject.send(self)
        }
    }
    
    // stateに変化があったらtrue を返す
    func healthCheck() -> Bool {
        switch self.state {
        case .adAct:
            if Date().timeIntervalSince(self.lastAdvRecvDate) > 5 {
                self.rssi = -100
                self.state = .adLost
                self.peripheralSubject.send(self)
                return true
            }
            return false
        default:
            return false
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
    }
    
}
