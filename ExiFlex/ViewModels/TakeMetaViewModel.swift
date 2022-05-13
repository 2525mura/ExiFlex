//
//  TakeMetaViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/05/13.
//

import Foundation
import Combine

final class TakeMetaViewModel: Identifiable, ObservableObject {
    
    let id: UUID = UUID()
    // 画面部品の状態変数
    @Published var isoValue: String
    @Published var fValue: String
    @Published var ssValue: String
    
    init(isoValue: String, fValue: String, ssValue: String) {
        self.isoValue = isoValue
        self.fValue = fValue
        self.ssValue = ssValue
    }
    
}
