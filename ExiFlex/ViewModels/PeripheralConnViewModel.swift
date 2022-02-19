//
//  PeripheralConnViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/02/18.
//

import Foundation

final class PeripheralConnViewModel: ObservableObject {
    
    let bleService: BleService
    let peripheralUuid: String
    let peripheralName: String?
    var state: BlePeripheralState = .adAct
    var shutterCount: Int

    init(bleService: BleService) {
        self.bleService = bleService
        self.peripheralUuid = "N/A"
        self.peripheralName = nil
        self.shutterCount = 0
    }
}
