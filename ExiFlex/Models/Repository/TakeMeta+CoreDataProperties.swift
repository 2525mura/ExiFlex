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
    @NSManaged public var isLeader: Bool
    @NSManaged public var isoValue: String?
    @NSManaged public var ssValue: String?
    @NSManaged public var takeDate: Date?
    @NSManaged public var takeNo: Int64
    @NSManaged public var refRoll: Roll?
    
    // 以下カスタマイズ
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
