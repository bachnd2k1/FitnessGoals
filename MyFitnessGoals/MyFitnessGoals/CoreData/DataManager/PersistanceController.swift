//
//  PersistanceController.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation
import CoreData

//struct PersistenceController {
//    let container: NSPersistentContainer
//
//    init() {
//        container = NSPersistentContainer(name: "Fitness")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}

struct PersistenceController {
    let container: NSPersistentContainer

    init(usingAppGroup: Bool = false) {
        container = NSPersistentContainer(name: "Fitness")

        let storeURL: URL

        if usingAppGroup {
            guard let groupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.yourcompany.fitness"
            ) else {
                fatalError("❌ Không tìm thấy App Group container.")
            }
            storeURL = groupURL.appendingPathComponent("Fitness.sqlite")
        } else {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            storeURL = directory.appendingPathComponent("Fitness.sqlite")
        }

        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("❌ Lỗi load persistent store: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
