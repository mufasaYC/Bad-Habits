//
//  UserDefaults+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CloudKit.CKServerChangeToken

extension UserDefaults {
    var didSubscribeToChanges: Bool {
        get {
            bool(forKey: "didSubscribeToChanges")
        } set {
            set(newValue, forKey: "didSubscribeToChanges")
        }
    }
}

extension UserDefaults {
    var previousServerChangeToken: CKServerChangeToken? {
        get {
            if let token = string(forKey: "previousServerChangeToken"),
               let data = Data(base64Encoded: token) {
                return try? NSKeyedUnarchiver.unarchivedObject(
                    ofClass: CKServerChangeToken.self,
                    from: data
                )
            }
            return nil
        } set {
            setValue(newValue?.asString(), forKey: "previousServerChangeToken")
        }
    }
    
    func setServerChangeToken(
        _ token: CKServerChangeToken?,
        for zoneID: CKRecordZone.ID
    ) {
        let key: String = "previousServerChangeToken-\(zoneID.zoneName)-\(zoneID.ownerName)"
        setValue(token?.asString(), forKey: key)
    }
    
    public func getServerChangeToken(
        for zoneID: CKRecordZone.ID
    ) -> CKServerChangeToken? {
        let key: String = "previousServerChangeToken-\(zoneID.zoneName)-\(zoneID.ownerName)"
        if let token = string(forKey: key),
           let data = Data(base64Encoded: token) {
            return try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: CKServerChangeToken.self,
                from: data
            )
        }
        return nil
    }
}
