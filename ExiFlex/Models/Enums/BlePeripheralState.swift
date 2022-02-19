//
//  BlePeripheralState.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/02/05.
//

import Foundation

public enum BlePeripheralState {
    // デバイス発見・接続（アドバタイズチャネル）
    case adAct
    case adLost
    case adConnectReq
    case adConnecting
    case adConnectFail
    // コネクション通信（データチャネル）
    case connAct
    case connLost
    case connClosed
}
