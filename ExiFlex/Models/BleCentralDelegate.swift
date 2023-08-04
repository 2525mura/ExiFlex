//
//  BleCentralDelegate.swift
//
//  BlueJinja Common library for iOS
//

import Foundation
import CoreBluetooth

protocol BleCentralDelegate {

    func peripheralDidDiscover(uuid: UUID, peripheral: CBPeripheral, rssi: Double)
    func peripheralDidUpdate(uuid: UUID, peripheral: CBPeripheral, rssi: Double)
    func peripheralDidDelete(uuid: UUID)
}
