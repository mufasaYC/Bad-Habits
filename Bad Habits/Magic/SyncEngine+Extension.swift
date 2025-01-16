//
//  SyncEngine+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import CloudKit
import CoreData

extension SyncEngine {
    func deleteZoneID(_ zoneID: CKRecordZone.ID) {
        let request = Problem.fetchRequest(with: zoneID.zoneName)
        let problems = try! self.managedObjectContext.fetch(request)
        problems.forEach { self.managedObjectContext.delete($0) }
    }
    
    func saveRecords(_ records: [CKRecord]) {
        records
            .filter { $0.recordType == "Problem" }
            .forEach { $0.save(context: managedObjectContext) }
        
        records
            .filter { $0.recordType == "BadHabit" }
            .forEach { $0.save(context: managedObjectContext) }
        
        records
            .filter { $0.recordType == "Oopsie" }
            .forEach { $0.save(context: managedObjectContext) }
        
        try! managedObjectContext.save()
    }
    
    func deleteRecords(_ records: [CKRecord.ID: CKRecord.RecordType]) {
        var objects: [NSManagedObject] = []
        for (recordID, recordType) in records {
            let id = recordID.recordName
            let request = NSFetchRequest<NSManagedObject>(entityName: recordType)
            request.predicate = .init(format: "id == %@", id)
            let fetchedObjects = try! self.managedObjectContext.fetch(request)
            objects.append(contentsOf: fetchedObjects)
        }
        objects.forEach { managedObjectContext.delete($0) }
        try! managedObjectContext.save()
    }
}
