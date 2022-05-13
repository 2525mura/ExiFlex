//
//  PeripheralAdvViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation

// アドバタイズから得たペリフェラルレベルの情報を保持するViewModel
final class PeripheralAdvViewModel: Identifiable, ObservableObject {
    let id: UUID = UUID()
    let peripheralUuid: String
    let peripheralName: String?
    @Published var blePower: Int
    @Published var rssi: Int
    @Published var state: BlePeripheralState
    
    init(peripheralUuid: String, peripheralName: String?, blePower: Int, rssi: Int, bleService: BleService) {
        self.peripheralUuid = peripheralUuid
        self.peripheralName = peripheralName
        self.blePower = blePower
        self.rssi = rssi
        self.state = .adAct
    }
    
}
