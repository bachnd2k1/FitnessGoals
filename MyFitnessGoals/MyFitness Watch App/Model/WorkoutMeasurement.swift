//
//  WorkoutMeasurement.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 9/6/25.
//

import Foundation

struct WorkoutMeasurement {
    let timestamp: TimeInterval
    let distance: Double
    let speed: Double
    let calories: Int
    let steps: Int
}

struct WorkoutState {
    var distance: Double = 0.0
    var speed: Double = 0.0
    var acceleration: Double = 0.0
    var steps: Int = 0
    var calories: Int = 0
    var heartRate: Double = 0.0
    var workoutType: WorkoutType = .running
}
