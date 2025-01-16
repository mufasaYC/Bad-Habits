//
//  BadHabit+CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import CloudKit.CKRecord

extension BadHabit: CKRecordConvertible {
    
    var zoneName: String? {
        problem?.id?.uuidString
    }
    
    func asCKRecord() -> CKRecord? {
        guard let record = self.buildCKRecord() else {
            return nil
        }
        
        record["title"] = title
        if let problemRecordID = problem?.ckRecordID {
            record["problem"] = CKRecord.Reference(
                recordID: problemRecordID,
                action: .deleteSelf
            )
        }
        return record
    }
    
    func update(with record: CKRecord) {
        self.id = UUID(uuidString: record.recordID.recordName)
        self.title = record["title"] as? String
        if let reference = record["problem"] as? CKRecord.Reference {
            let problemID = reference.recordID.recordName
            let request = Problem.fetchRequest(with: problemID)
            let problems = try! managedObjectContext?.fetch(request)
            if let problem = problems?.first {
                self.problem = problem
            }
        }
        self.encodedSystemFields = record.encodedSystemFields
    }
}
