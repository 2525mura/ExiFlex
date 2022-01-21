//
//  BlePeripheralModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/14.
//

import Foundation
import CoreBluetooth

class BlePeripheralModel {
    
    var peripheral: CBPeripheral
    var rssi : Double
    // Advertise最終受信日時
    var lastAdvRecvDate: Date
    var isLostAdv: Bool
    var isConnect: Bool

    init(peripheral: CBPeripheral, rssi: Double) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.lastAdvRecvDate = Date()
        self.isLostAdv = false
        self.isConnect = false
    }
    
    // ペリフェラルのUUIDを返す
    var peripheralUuid: String {
        get {
            return peripheral.identifier.uuidString
        }
    }
    // ペリフェラルの名前を返す
    var peripheralName: String? {
        get {
            return peripheral.name
        }
    }
}
