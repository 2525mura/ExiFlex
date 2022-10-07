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
    @NSManaged public var rollBrand: String?
    @NSManaged public var rollName: String?
    @NSManaged public var takeCount: Int64
    @NSManaged public var rollTypeValue: Int64
    @NSManaged public var takeMetas: NSSet?

    // 以下カスタマイズ
    // NSSet? → [TakeMeta]変換
    public var takeMetasList: [TakeMeta] {
        let set = takeMetas as? Set<TakeMeta> ?? []
        return set.sorted {
            $0.takeNo < $1.takeNo
        }
    }
    public var rollBrandUnwrap: String { rollBrand ?? "N/A" }
    public var rollNameUnwrap: String { rollName ?? "N/A" }
    public var createdAtUnwrap: Date { createdAt ?? Date() }
    // RollType変換
    var rollType: RollType {
        // To get a RollType enum from rollTypeValue, initialize the
        // RollType type from the Int64 value rollTypeValue
        get {
            return RollType(rawValue: self.rollTypeValue)!
        }

        // newValue will be of type RollType, thus rawValue will
        // be an Int64 value that can be saved in Core Data
        set {
            self.rollTypeValue = newValue.rawValue
        }
    }
    
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

// MARK: injection data for preview
extension Roll {
    // Example roll for Xcode previews
    static var example: Roll {
        // Get the first roll from the in-memory Core Data store
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest: NSFetchRequest<Roll> = Roll.fetchRequest()
        fetchRequest.fetchLimit = 1
        let results = try? context.fetch(fetchRequest)
        return (results?.first!)!
    }
}
