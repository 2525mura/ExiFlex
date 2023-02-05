//
//  BleCharacteristicModel.swift
//  ExiFlex
//
//  Created by mac on 2023/02/04.
//

import Foundation
import CoreBluetooth

class BleCharacteristicModel {
    
    var alias: String
    private var characteristicConnect: CBCharacteristic?
    
    init(alias: String) {
        self.alias = alias
    }
    
    func setCharacteristic(characteristic: CBCharacteristic) {
        self.characteristicConnect = characteristic
    }
    
    func getCharacteristic() -> CBCharacteristic? {
        return self.characteristicConnect
    }
}
