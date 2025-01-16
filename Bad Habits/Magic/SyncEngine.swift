//
//  SyncEngine.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CloudKit
import CoreData

class SyncEngine {
    
    static let shared: SyncEngine = .init()
    
    let managedObjectContext: NSManagedObjectContext = PersistenceController.shared.viewContext
    private let container: CKContainer = .init(identifier: "iCloud.com.myc.test")
    
    private init() {
        subscribeToChanges(in: .private)
    }
    
    // ck_subscription_1, _2
    private func subscribeToChanges(in scope: CKDatabase.Scope) {
        guard UserDefaults.standard.didSubscribeToChanges else {
            return
        }
        
        let subscription = CKDatabaseSubscription(subscriptionID: "changes")
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        Task {
            _ = try! await container.privateCloudDatabase.modifySubscriptions(
                saving: [subscription],
                deleting: []
            )
            UserDefaults.standard.didSubscribeToChanges = true
        }
    }
    
    // ck_sync_record
    func syncObject(_ object: CKRecordConvertible) {
        guard let record = object.asCKRecord() else {
            fatalError()
        }
        
        let database = container.database(with: object.databaseScope)
        Task {
            do {
                try await database.save(record)
            } catch let error as CKError {
                switch error.code {
                    case .zoneNotFound:
                        try! await database.save(.init(zoneID: object.zoneID!))
                        syncObject(object)
                    default:
                        fatalError()
                }
            } catch {
                fatalError()
            }
            
        }
    }
    
    // ck_delete_zone
    func deleteZone(_ object: CKRecordConvertible) {
        let database = container.database(with: object.databaseScope)
        Task {
            try! await database.deleteRecordZone(withID: object.zoneID!)
        }
    }
    
    // ck_delete_record
    func deleteObject(_ object: CKRecordConvertible) {
        let database = container.database(with: object.databaseScope)
        Task {
            try! await database.deleteRecord(withID: object.ckRecordID!)
        }
    }
    
    @MainActor
    func fetchChanges(in scope: CKDatabase.Scope) async {
        
        // ck_fetch_zone_changes
        
        var moreComing: Bool = true
        
        let database = container.database(with: scope)
        var token = UserDefaults.standard.previousServerChangeToken
        
        var newZoneIDs: [CKRecordZone.ID] = []
        
        while moreComing {
            let result = try! await database.databaseChanges(since: token)
            moreComing = result.moreComing
            token = result.changeToken
            
            result.modifications.forEach {
                newZoneIDs.append($0.zoneID)
            }
            
            result.deletions.forEach { deletion in
                deleteZoneID(deletion.zoneID)
            }
        }
        
        UserDefaults.standard.previousServerChangeToken = token
        
        let existingProblemsRequest = Problem.fetchRequest()
        let existingProblems = try! managedObjectContext.fetch(existingProblemsRequest)
        
        var allZoneIDs = existingProblems
            .filter { $0.databaseScope == scope }
            .compactMap { $0.zoneID }
        allZoneIDs.append(contentsOf: newZoneIDs)

        // ck_fetch_existing_zones
                        
        // ck_fetch_zone_changes_config
        
        // ck_fetch_zone_changes
        
        var config: [CKRecordZone.ID : CKFetchRecordZoneChangesOperation.ZoneConfiguration] = [:]
        
        allZoneIDs.forEach {
            let token = UserDefaults.standard.getServerChangeToken(for: $0)
            config.updateValue(
                .init(previousServerChangeToken: token), forKey: $0)
        }
        
        var recordsToSave: [CKRecord] = []
        var recordsToDelete: [CKRecord.ID: CKRecord.RecordType] = [:]
        
        await withCheckedContinuation { continuation in
            let operation = CKFetchRecordZoneChangesOperation.init(
                recordZoneIDs: allZoneIDs,
                configurationsByRecordZoneID: config
            )
            
            operation.recordWasChangedBlock = { recordID, result in
                recordsToSave.append(try! result.get())
            }
            
            operation.recordWithIDWasDeletedBlock = { recordID, recordType in
                recordsToDelete.updateValue(recordType, forKey: recordID)
            }
            
            operation.recordZoneChangeTokensUpdatedBlock = { zoneID, token, _ in
                UserDefaults.standard.setServerChangeToken(token, for: zoneID)
            }
            
            operation.completionBlock = {
                continuation.resume()
            }
            
            database.add(operation)
        }
        
        self.saveRecords(recordsToSave)
        self.deleteRecords(recordsToDelete)
    }
}

