//
//  Roll+CoreDataClass.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/25.
//
//

import Foundation
import CoreData

@objc(Roll)
public class Roll: NSManagedObject {
    
    func addLeader(viewContext: NSManagedObjectContext) {
        // リーダーメタ情報を作成
        let takeMeta = TakeMeta(context: viewContext)
        takeMeta.id = UUID()
        takeMeta.isoValue = "N/A"
        takeMeta.fValue = "N/A"
        takeMeta.ssValue = "N/A"
        takeMeta.takeNo = -1
        takeMeta.takeDate = Date()
        takeMeta.isLeader = true
        takeMeta.refRoll = self
        // ロール情報を更新
        self.addToTakeMetas(takeMeta)
        // 保存
        try? viewContext.save()
    }

    func take(viewContext: NSManagedObjectContext, isoValue: String, fValue: String, ssValue: String) -> TakeMeta {
        // 撮影メタ情報を作成
        let takeMeta = TakeMeta(context: viewContext)
        takeMeta.id = UUID()
        takeMeta.isoValue = isoValue
        takeMeta.fValue = fValue
        takeMeta.ssValue = ssValue
        takeMeta.takeNo = self.takeCount
        takeMeta.takeDate = Date()
        takeMeta.isLeader = false
        takeMeta.refRoll = self
        // ロール情報を更新
        self.addToTakeMetas(takeMeta)
        self.takeCount += 1
        // 保存
        try? viewContext.save()
        return takeMeta
    }

}
