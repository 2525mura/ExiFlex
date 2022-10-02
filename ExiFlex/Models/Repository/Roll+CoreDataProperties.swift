//
//  Roll+CoreDataProperties.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/25.
//
//

import Foundation
import CoreData


extension Roll {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Roll> {
        return NSFetchRequest<Roll>(entityName: "Roll")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var rollName: String?
    @NSManaged public var takeCount: Int64
    @NSManaged public var takeMetas: NSSet?

    // 以下カスタマイズ
    // NSSet? → [TakeMeta]変換
    public var takeMetasList: [TakeMeta] {
        let set = takeMetas as? Set<TakeMeta> ?? []
        return set.sorted {
            $0.takeNo < $1.takeNo
        }
    }
    public var rollNameUnwrap: String { rollName ?? "N/A" }
    public var createdAtUnwrap: Date { createdAt ?? Date() }
    
}

// MARK: Generated accessors for takeMetas
extension Roll {

    @objc(addTakeMetasObject:)
    @NSManaged public func addToTakeMetas(_ value: TakeMeta)

    @objc(removeTakeMetasObject:)
    @NSManaged public func removeFromTakeMetas(_ value: TakeMeta)

    @objc(addTakeMetas:)
    @NSManaged public func addToTakeMetas(_ values: NSSet)

    @objc(removeTakeMetas:)
    @NSManaged public func removeFromTakeMetas(_ values: NSSet)

}

extension Roll : Identifiable {

}
