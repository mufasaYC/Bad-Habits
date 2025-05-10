//
//  Problem+CKRecordConvertible.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 16/01/25.
//

import CloudKit.CKRecord
import MYCloudKit

extension Problem: MYRecordConvertible {
    
    public var myRecordID: String {
        self.id?.uuidString ?? UUID().uuidString
    }
    
    public var myRecordType: String {
        "Problem"
    }
    
    public var myRootGroupID: String? {
        switch AppState.shared.shareType {
            case .recordWithMYZone:
                return nil
            case .zone, .recordWithCustomZone:
                return id?.uuidString
        }
    }
    
    public var myParentID: String? {
        nil
    }
    
    public var myProperties: [String: MYRecordValue] {
        [
            "title": .string(title),
        ]
    }
}
