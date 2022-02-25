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
    var state: BlePeripheralState
    @Published var shutterCount: Int

    init(peripheralUuid: String, peripheralName: String?, bleService: BleService) {
        self.bleService = bleService
        self.peripheralUuid = peripheralUuid
        self.peripheralName = peripheralName
        self.state = .adAct
        self.shutterCount = 0
    }
}
