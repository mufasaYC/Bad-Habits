//
//  Oopsie+CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import CloudKit.CKRecord
import MYCloudKit

extension Oopsie: MYRecordConvertible {
    
    public var myRecordID: String {
        self.id?.uuidString ?? UUID().uuidString
    }
    
    public var myRecordType: String {
        "Oopsie"
    }
    
    public var myRootGroupID: String? {
        switch AppState.shared.shareType {
            case .recordWithMYZone:
                return nil
            case .zone, .recordWithCustomZone:
                return badHabit?.problem?.id?.uuidString
        }
    }
    
    public var myParentID: String? {
        switch AppState.shared.shareType {
            case .recordWithMYZone, .recordWithCustomZone:
                return badHabit?.id?.uuidString
            case .zone:
                return nil
        }
    }
    
    public var myProperties: [String: MYRecordValue] {
        [
            "timestamp": .date(timestamp),
            "badHabit": .reference(badHabit, deleteRule: .deleteSelf)
        ]
    }
}
