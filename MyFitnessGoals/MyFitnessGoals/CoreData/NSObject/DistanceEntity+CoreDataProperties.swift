//
//  DistanceEntity+CoreDataProperties.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 21/01/2025.
//
//

import Foundation
import CoreData


extension DistanceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DistanceEntity> {
        return NSFetchRequest<DistanceEntity>(entityName: "DistanceEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var distance: Double
    @NSManaged public var id: UUID?
    @NSManaged public var type: Int16
    @NSManaged public var workoutType: Int16
    @NSManaged public var workout: WorkoutEntity?

}

extension DistanceEntity : Identifiable {

}
