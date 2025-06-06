//
//  WorkoutEntity+CoreDataProperties.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 21/01/2025.
//
//

import Foundation
import CoreData


extension WorkoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
        return NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
    }

    @NSManaged public var altitudes: [Double]?
    @NSManaged public var date: Date?
    @NSManaged public var distances: [Double]?
    @NSManaged public var duration: Double
    @NSManaged public var routeLatitudes: [Double]?
    @NSManaged public var routeLongitudes: [Double]?
    @NSManaged public var speeds: [Double]?
    @NSManaged public var type: Int16
    @NSManaged public var uuid: UUID?
    @NSManaged public var calories: CalorieEntity?
    @NSManaged public var distance: DistanceEntity?
    @NSManaged public var speed: SpeedEntity?
    @NSManaged public var steps: StepEntity?

}

extension WorkoutEntity : Identifiable {

}
