//
//  Problem+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CoreData

extension Problem {
    class func fetchRequest(with id: String) -> NSFetchRequest<Problem> {
        let request = Problem.fetchRequest()
        if let uuid = UUID(uuidString: id) {
            request.predicate = .init(format: "id == %@", uuid as CVarArg)
        }
        request.fetchLimit = 1
        return request
    }
}
