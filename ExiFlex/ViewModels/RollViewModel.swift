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
    let takeMetaViewModels: [TakeMetaViewModel]
    var takeCount: Int
    
    init(rollName: String) {
        self.rollName = rollName
        self.takeMetaViewModels = []
        self.takeCount = 0
    }
    
}
