//
//  RollEditViewModel.swift
//  ExiFlex
//
//  Created by mac on 2022/10/19.
//

import Foundation
import CoreData

class RollEditViewModel: ObservableObject {
    
    public var createdAt: Date
    public var rollBrand: String
    public var rollName: String
    public var takeCount: Int64
    public var rollType: RollType
    private(set) var editRoll: Roll?
    
    // roll==nilなら新規作成、そうでなければ更新
    init(_ roll: Roll? = nil) {
        
        self.createdAt = Date()
        self.rollBrand = ""
        self.rollName = ""
        self.takeCount = 0
        self.rollType = .colorReversal
        self.editRoll = nil
        
        if roll != nil {
            self.createdAt = roll!.createdAt ?? Date()
            self.rollBrand = roll!.rollBrand ?? ""
            self.rollName = roll!.rollName ?? ""
            self.takeCount = roll!.takeCount
            self.rollType = roll!.rollType
            self.editRoll = roll!
        }
    }
    
    func save(viewContext: NSManagedObjectContext) {
        
        if self.editRoll == nil {
            self.editRoll = Roll(context: viewContext)
            self.editRoll?.id = UUID()
            self.editRoll?.addLeader(viewContext: viewContext)
        }
        self.editRoll?.rollBrand = self.rollBrand
        self.editRoll?.rollName = self.rollName
        self.editRoll?.rollType = self.rollType
        self.editRoll?.takeCount = self.takeCount
        self.editRoll?.createdAt = self.createdAt
        // 保存
        try? viewContext.save()
    }
    
}
