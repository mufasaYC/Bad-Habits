//
//  Persistence.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 14/01/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    private let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext

    init() {
        container = NSPersistentContainer(name: "Bad_Habits")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        viewContext = container.viewContext
    }
}
