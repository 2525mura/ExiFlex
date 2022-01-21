//
//  DevAdvViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/01/09.
//

import Foundation

struct DevAdvViewModel: Identifiable {
    let id: UUID = UUID()
    let periUuidString: String
    let devName: String?
    var blePower: Int
    var rssi: Int
    var isLostAdv: Bool = false
}
