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
    var takeCount: Int
    let takeDate: Date
    let takeDateStr: String
    let isLeader: Bool
    let refRoll: RollViewModel
    
    init(refRoll: RollViewModel, isoValue: String, fValue: String, ssValue: String, takeCount: Int, isLeader: Bool = false) {
        self.refRoll = refRoll
        self.isoValue = isoValue
        self.fValue = fValue
        self.ssValue = ssValue
        self.takeCount = takeCount
        self.isLeader = isLeader
        
        // 撮影日時
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        self.takeDate = Date()
        self.takeDateStr = f.string(from: self.takeDate)
    }
    
}
