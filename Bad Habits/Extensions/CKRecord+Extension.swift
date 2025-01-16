//
//  CKRecord+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CloudKit.CKRecord
import CoreData

extension CKRecord {
    
    convenience init?(data: Data) {
        do {
            let coder = try NSKeyedUnarchiver(forReadingFrom: data)
            coder.requiresSecureCoding = true
            self.init(coder: coder)
            coder.finishDecoding()
        } catch {
            return nil
        }
    }
    
    var encodedSystemFields: Data {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        self.encodeSystemFields(with: coder)
        return coder.encodedData
    }
}

extension CKRecord {
    
    /// recordType and the local CoreData entity names are the same, so we can do this
    func save(context: NSManagedObjectContext) {
        let id = recordID.recordName
        let request = NSFetchRequest<NSManagedObject>(entityName: recordType)
        request.predicate = .init(format: "id == %@", UUID(uuidString: id)! as CVarArg)
        let existingObject = try! context.fetch(request).first
        let object: CKRecordConvertible
        switch recordType {
            case "Problem":
                object = (existingObject as? Problem) ?? Problem(context: context)
            case "BadHabit":
                object = (existingObject as? BadHabit) ?? BadHabit(context: context)
            case "Oopsie":
                object = (existingObject as? Oopsie) ?? Oopsie(context: context)
            default:
                fatalError()
        }
        object.update(with: self)
    }
}
