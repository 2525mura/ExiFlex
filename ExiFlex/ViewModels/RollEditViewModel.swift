//
//  RollEditViewModel.swift
//  ExiFlex
//
//  Created by mac on 2022/10/02.
//

import Foundation
import CoreData

final class RollEditViewModel: ObservableObject {
    
    private(set) var viewContext: NSManagedObjectContext
    @Published var editRoll: Roll
    let rollBrands = ["Fujifilm Provia100", "Fujifilm Velvia100"]
    
    // 編集画面とbindする表示
    @Published var rollName: String = ""
    @Published var rollBrand: String = ""
    @Published var createdAt: Date = Date()
    
    init(viewContext: NSManagedObjectContext, roll: Roll?) {
        self.viewContext = viewContext
        if roll == nil {
            self.editRoll = Roll(context: viewContext)
            self.editRoll.id = UUID()
            self.editRoll.takeCount = 0
            self.editRoll.createdAt = Date()
        } else {
            self.editRoll = roll!
            self.rollName = self.editRoll.rollNameUnwrap
            self.createdAt = self.editRoll.createdAtUnwrap
        }
    }
    
    
}
