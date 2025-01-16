//
//  Oopsie+Extension.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 15/01/25.
//

import CoreData

extension Oopsie {
    class func fetchRequest(for badHabit: BadHabit) -> NSFetchRequest<Oopsie> {
        let request = Oopsie.fetchRequest()
        request.predicate = .init(format: "badHabit == %@", badHabit)
        request.sortDescriptors = [.init(keyPath: \Oopsie.timestamp, ascending: false)]
        return request
    }
    
    class func fetchRequest(for badHabit: BadHabit, startDate: Date, endDate: Date) -> NSFetchRequest<Oopsie> {
        let request = Oopsie.fetchRequest()
        request.predicate = .init(
            format: "badHabit == %@ AND timestamp >= %@ AND timestamp <= %@",
            badHabit,
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [.init(keyPath: \Oopsie.timestamp, ascending: false)]
        return request
    }
}

extension Oopsie {
    class func fetchRequest(with id: String) -> NSFetchRequest<Oopsie> {
        let request = Oopsie.fetchRequest()
        if let uuid = UUID(uuidString: id) {
            request.predicate = .init(format: "id == %@", uuid as CVarArg)
        }
        request.fetchLimit = 1
        return request
    }
}
