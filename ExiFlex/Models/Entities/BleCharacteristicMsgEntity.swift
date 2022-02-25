//
//  BleCharacteristicMsgEntity.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/02/25.
//

import Foundation

// BLEキャラクタリスティックの受信メッセージを格納するEntity
struct BleCharacteristicMsgEntity {
    let peripheralUuid: String
    let serviceUuid: String
    let characteristicUuid: String
    let characteristicData: String
}
