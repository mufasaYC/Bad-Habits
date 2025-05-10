//
//  BadHabit+CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import MYCloudKit
import CloudKit.CKRecord

extension BadHabit: MYRecordConvertible {
    
    public var myRecordID: String {
        self.id?.uuidString ?? UUID().uuidString
    }
    
    public var myRecordType: String {
        "BadHabit"
    }
    
    public var myRootGroupID: String? {
        switch AppState.shared.shareType {
            case .recordWithMYZone:
                return nil
            case .zone, .recordWithCustomZone:
                return problem?.id?.uuidString
        }
    }
    
    public var myParentID: String? {
        switch AppState.shared.shareType {
            case .recordWithMYZone, .recordWithCustomZone:
                return problem?.id?.uuidString
            case .zone:
                return nil
        }
    }
    
    public var myProperties: [String: MYRecordValue] {
        [
            "title": .string(title),
            "problem": .reference(problem, deleteRule: .deleteSelf),
        ]
    }
}
