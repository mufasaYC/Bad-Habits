//
//  BadHabit+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CoreData

extension BadHabit {
    class func fetchRequest(for problem: Problem) -> NSFetchRequest<BadHabit> {
        let request = BadHabit.fetchRequest()
        request.predicate = .init(format: "problem == %@", problem)
        request.sortDescriptors = [.init(keyPath: \BadHabit.title, ascending: true)]
        return request
    }
}

extension BadHabit {
    class func fetchRequest(with id: String) -> NSFetchRequest<BadHabit> {
        let request = BadHabit.fetchRequest()
        if let uuid = UUID(uuidString: id) {
            request.predicate = .init(format: "id == %@", uuid as CVarArg)
        }
        request.fetchLimit = 1
        return request
    }
}
