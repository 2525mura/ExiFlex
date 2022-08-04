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
        self.takeMetaViewModels = []
        addLeader()
    }
    
    func addLeader() {
        let takeMetaViewModel = TakeMetaViewModel(refRoll: self, isoValue: "N/A", fValue: "N/A", ssValue: "N/A", takeCount: -1, isLeader: true)
        self.takeMetaViewModels.append(takeMetaViewModel)
    }
    
    func take(isoValue: String, fValue: String, ssValue: String) -> TakeMetaViewModel {
        let takeMetaViewModel = TakeMetaViewModel(
            refRoll: self,
            isoValue: isoValue,
            fValue: fValue,
            ssValue: ssValue,
            takeCount: self.takeCount
        )
        self.takeMetaViewModels.append(takeMetaViewModel)
        self.takeCount += 1
        return takeMetaViewModel
    }
    
}
