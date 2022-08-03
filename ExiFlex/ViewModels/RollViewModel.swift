//
//  RollViewModel.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/07/27.
//

import Foundation

final class RollViewModel: Identifiable {
    
    let id: UUID = UUID()
    let rollName: String
    var takeMetaViewModels: [TakeMetaViewModel]
    var takeCount: Int
    
    init(rollName: String) {
        self.rollName = rollName
        self.takeCount = 0
        self.takeMetaViewModels = [
            TakeMetaViewModel(isoValue: "N/A", fValue: "N/A", ssValue: "N/A", takeCount: self.takeCount)
        ]
    }
    
}
