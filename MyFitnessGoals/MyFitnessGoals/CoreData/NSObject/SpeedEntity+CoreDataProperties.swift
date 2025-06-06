//
//  SpeedEntity+CoreDataProperties.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 21/01/2025.
//
//

import Foundation
import CoreData


extension SpeedEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpeedEntity> {
        return NSFetchRequest<SpeedEntity>(entityName: "SpeedEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var speed: Double
    @NSManaged public var type: Int16
    @NSManaged public var workoutType: Int16
    @NSManaged public var workout: WorkoutEntity?

}

extension SpeedEntity : Identifiable {

}
