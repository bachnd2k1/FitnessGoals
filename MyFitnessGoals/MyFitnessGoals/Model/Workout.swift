//
//  Workout.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation
import CoreLocation

struct Workout: Identifiable, Hashable {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let date: Date?
    let type: WorkoutType?
    let route: [CLLocation]?
    let duration: Double
    let distance: Distance? // total distance
    let speed: Speed? // average speed
    let distances: [Measurement<UnitLength>]?
    let speeds: [Measurement<UnitSpeed>]?
    let altitudes: [Measurement<UnitLength>]?
    let steps: Step?
    let calories: Calorie?
}
