//
//  Problem+CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import CloudKit.CKRecord

extension Problem: CKRecordConvertible {
    
    var zoneName: String? {
        id?.uuidString
    }
    
    func asCKRecord() -> CKRecord? {
        guard let record = self.buildCKRecord() else {
            return nil
        }
        
        record["title"] = title
        return record
    }
    
    func update(with record: CKRecord) {
        self.id = UUID(uuidString: record.recordID.recordName)
        self.title = record["title"] as? String
        self.encodedSystemFields = record.encodedSystemFields
    }
}
