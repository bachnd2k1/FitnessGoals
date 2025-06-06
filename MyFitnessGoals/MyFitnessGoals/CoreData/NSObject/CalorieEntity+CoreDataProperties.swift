//
//  CalorieEntity+CoreDataProperties.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 21/01/2025.
//
//

import Foundation
import CoreData


extension CalorieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalorieEntity> {
        return NSFetchRequest<CalorieEntity>(entityName: "CalorieEntity")
    }

    @NSManaged public var calorie: Int16
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var type: Int16
    @NSManaged public var workoutType: Int16
    @NSManaged public var workout: WorkoutEntity?

}

extension CalorieEntity : Identifiable {

}
