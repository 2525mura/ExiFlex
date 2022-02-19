//
//  PeripheralAdvViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation

struct PeripheralAdvViewModel: Identifiable {
    let id: UUID = UUID()
    let peripheralUuid: String
    let peripheralName: String?
    var blePower: Int
    var rssi: Int
    var state: BlePeripheralState = .adAct
}
