//
//  CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CloudKit
import CoreData

protocol CKRecordConvertible: NSManagedObject {
    var id: UUID? { get set }
    var zoneName: String? { get }
    
    var encodedSystemFields: Data? { get }
    
    var zoneID: CKRecordZone.ID? { get }
    
    func asCKRecord() -> CKRecord?
    var ckRecordID: CKRecord.ID? { get }
    
    func update(with record: CKRecord)
}

extension CKRecordConvertible {
    var recordType: String { entity.name! }
    
    var databaseScope: CKDatabase.Scope {
        guard let zoneID else {
            fatalError()
        }
        if zoneID.ownerName == CKCurrentUserDefaultName {
            return .private
        } else {
            return .shared
        }
    }
    
    func buildCKRecord() -> CKRecord? {
        if let encodedSystemFields {
            return .init(data: encodedSystemFields)
        }
        
        guard let id = id?.uuidString,
              let zoneName else {
            return nil
        }
        
        return .init(
            recordType: recordType,
            recordID: .init(
                recordName: id,
                zoneID: .init(zoneName: zoneName)
            )
        )
    }
    
    var ckRecordID: CKRecord.ID? {
        buildCKRecord()?.recordID
    }
    
    var zoneID: CKRecordZone.ID? {
        buildCKRecord()?.recordID.zoneID
    }
}
