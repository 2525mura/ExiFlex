//
//  BleServiceDelegate.swift
//
//  BlueJinja Common library for iOS
//

import Foundation
import CoreBluetooth

protocol BleServiceDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverService service: CBService, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
}
