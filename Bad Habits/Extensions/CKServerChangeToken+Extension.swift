//
//  CKServerChangeToken+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CloudKit.CKServerChangeToken

extension CKServerChangeToken {
    
    func asString() -> String? {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return data.base64EncodedString()
        } catch {
            assertionFailure()
            return nil
        }
    }
}
