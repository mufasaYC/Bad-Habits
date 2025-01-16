//
//  Oopsie+CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import CloudKit.CKRecord

extension Oopsie: CKRecordConvertible {
    var zoneName: String? {
        badHabit?.problem?.id?.uuidString
    }
    
    func asCKRecord() -> CKRecord? {
        guard let record = self.buildCKRecord() else {
            return nil
        }

        record["timestamp"] = timestamp
        if let badHabitRecordID = badHabit?.ckRecordID {
            record["badHabit"] = CKRecord.Reference(
                recordID: badHabitRecordID,
                action: .deleteSelf
            )
        }
        return record
    }
    
    func update(with record: CKRecord) {
        self.id = UUID(uuidString: record.recordID.recordName)
        self.timestamp = record["timestamp"] as? Date
        if let reference = record["badHabit"] as? CKRecord.Reference {
            let badHabitID = reference.recordID.recordName
            let request = BadHabit.fetchRequest(with: badHabitID)
            let badHabits = try! managedObjectContext?.fetch(request)
            if let badHabit = badHabits?.first {
                self.badHabit = badHabit
            }
        }
        self.encodedSystemFields = record.encodedSystemFields
    }
}
