//
//  BlePeripheralState.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/02/05.
//

import Foundation

public enum BlePeripheralState {
    // アドバタイズフェーズ
    case adAct
    case adLost
    case adConnectReq
    case adConnecting
    case adConnectFail
    // コネクション通信フェーズ
    case connAct
    case connLost
    case connError
    case connDisconnecting
    case connDisconnected
}
