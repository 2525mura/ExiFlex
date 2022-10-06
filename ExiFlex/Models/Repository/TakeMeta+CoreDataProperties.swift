//
//  TakeMeta+CoreDataProperties.swift
//  ExiFlex
//
//  Created by 村井慎太郎 on 2022/08/25.
//
//

import Foundation
import CoreData


extension TakeMeta {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TakeMeta> {
        return NSFetchRequest<TakeMeta>(entityName: "TakeMeta")
    }

    @NSManaged public var fValue: String?
    @NSManaged public var id: UUID?
    @NSManaged public var frameTypeValue: Int64
    @NSManaged public var isoValue: String?
    @NSManaged public var latitude: Double
    @NSManaged public var locationActive: Bool
    @NSManaged public var longitude: Double
    @NSManaged public var ssValue: String?
    @NSManaged public var takeDate: Date?
    @NSManaged public var takeNo: Int64
    @NSManaged public var refRoll: Roll?
    
    // 以下カスタマイズ
    var frameType: FrameType {
        // To get a FrameType enum from frameTypeValue, initialize the
        // FrameType type from the Int64 value frameTypeValue
        get {
            return FrameType(rawValue: self.frameTypeValue)!
        }

        // newValue will be of type FrameType, thus rawValue will
        // be an Int64 value that can be saved in Core Data
        set {
            self.frameTypeValue = newValue.rawValue
        }
    }
    
    public var takeDateStr: String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        if let unwrapDate = takeDate {
            return f.string(from: unwrapDate)
        }
        return "NO DATE"
    }
    public var fValueUnwrap: String { fValue ?? "N/A" }
    public var isoValueUnwrap: String { isoValue ?? "N/A" }
    public var ssValueUnwrap: String { ssValue ?? "N/A" }
    
}

extension TakeMeta : Identifiable {

}

// MARK: injection data for preview
extension TakeMeta {
    // Example take_meta for Xcode previews
    static var example: TakeMeta {
        // Get the first take_meta from the in-memory Core Data store
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest: NSFetchRequest<TakeMeta> = TakeMeta.fetchRequest()
        fetchRequest.fetchLimit = 1
        let results = try? context.fetch(fetchRequest)
        return (results?.first!)!
    }
}
