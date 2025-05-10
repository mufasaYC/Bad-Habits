//
//  AppState.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import MYCloudKit
import Foundation

@Observable
final class AppState {
    enum ShareType {
        case zone
        case recordWithMYZone
        case recordWithCustomZone
    }
    static let shared: AppState = .init()
    let shareType: ShareType = .recordWithCustomZone
    
    var sheet: Sheet? = nil
    let syncEngine: MYSyncEngine
    
    private init() {
        self.syncEngine = .init(
            containerIdentifier: "iCloud.com.myc.test",
            logLevel: .debug
        )
        self.syncEngine.delegate = self
    }
}

extension AppState: MYSyncDelegate {
    func didReceiveRecordsToSave(_ records: [MYSyncEngine.FetchedRecord]) {
        let context = PersistenceController.shared.viewContext
        
        context.perform {
            for record in records {
                switch record.type {
                    case "Problem":
                        let request = Problem.fetchRequest(with: record.id)
                        let problem = (try? context.fetch(request).first) ?? Problem(context: context)
                        problem.id = .init(uuidString: record.id)
                        problem.title = record.value(for: "title")
                    case "BadHabit":
                        let request = BadHabit.fetchRequest(with: record.id)
                        let badHabit = (try? context.fetch(request).first) ?? BadHabit(context: context)
                        badHabit.id = .init(uuidString: record.id)
                        badHabit.title = record.value(for: "title")
                        
                        let problemID: String?
                        switch self.shareType {
                            case .recordWithMYZone, .recordWithCustomZone:
                                problemID = record.parentID
                            case .zone:
                                problemID = record.value(for: "problem")
                        }
                        if let problemID {
                            let request = Problem.fetchRequest(with: problemID)
                            let problem = try? context.fetch(request).first
                            badHabit.problem = problem
                        }
                    case "Oopsie":
                        let request = Oopsie.fetchRequest(with: record.id)
                        let oopsie = (try? context.fetch(request).first) ?? Oopsie(context: context)
                        oopsie.id = .init(uuidString: record.id)
                        oopsie.timestamp = record.value(for: "timestamp")
                        
                        let badHabitID: String?
                        switch self.shareType {
                            case .recordWithMYZone, .recordWithCustomZone:
                                badHabitID = record.parentID
                            case .zone:
                                badHabitID = record.value(for: "badHabit")
                        }
                        
                        if let badHabitID {
                            let request = BadHabit.fetchRequest(with: badHabitID)
                            let badHabit = try? context.fetch(request).first
                            oopsie.badHabit = badHabit
                        }
                    default:
                        assertionFailure()
                }
            }
            try! context.save()
        }
    }
    
    func didReceiveRecordsToDelete(_ records: [(myRecordID: String, myRecordType: MYRecordType)]) {
        let context = PersistenceController.shared.viewContext
        context.perform {
            for record in records {
                switch record.myRecordType {
                    case "Problem":
                        let request = Problem.fetchRequest(with: record.myRecordID)
                        if let problem = try? context.fetch(request).first {
                            context.delete(problem)
                        }
                        
                    case "BadHabit":
                        let request = BadHabit.fetchRequest(with: record.myRecordID)
                        if let badHabit = try? context.fetch(request).first {
                            context.delete(badHabit)
                        }
                        
                    case "Oopsie":
                        let request = Oopsie.fetchRequest(with: record.myRecordID)
                        if let oopsie = try? context.fetch(request).first {
                            context.delete(oopsie)
                        }
                        
                    default:
                        fatalError()
                }
            }
            
            try! context.save()
        }
    }
        
    func didReceiveGroupIDsToDelete(_ ids: [String]) {
        let context = PersistenceController.shared.viewContext
        context.perform {
            for id in ids {
                let problemRequest = Problem.fetchRequest(with: id)
                if let problem = try? context.fetch(problemRequest).first {
                    context.delete(problem)
                }
                
                let badHabitRequest = BadHabit.fetchRequest(with: id)
                if let badHabit = try? context.fetch(badHabitRequest).first {
                    context.delete(badHabit)
                }
            }
            
            try! context.save()
        }
    }
    
    func handleUnsyncableRecord(
        recordID: String,
        recordType: MYRecordType,
        reason: String,
        error: any Error
    ) -> [any MYRecordConvertible]? {
        nil
    }
    
    func syncableRecordTypesInDependencyOrder() -> [MYRecordType] {
        return ["Problem", "BadHabit", "Oopsie"]
    }
}
