//
//  StepEntity+CoreDataProperties.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 21/01/2025.
//
//

import Foundation
import CoreData


extension StepEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StepEntity> {
        return NSFetchRequest<StepEntity>(entityName: "StepEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var step: Int16
    @NSManaged public var type: Int16
    @NSManaged public var workoutType: Int16
    @NSManaged public var workout: WorkoutEntity?

}

extension StepEntity : Identifiable {

}
