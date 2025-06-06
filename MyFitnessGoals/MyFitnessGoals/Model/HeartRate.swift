//
//  HeartRate.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 6/5/25.
//

import Foundation

struct HeartRate: BaseFitnessModel, Hashable {
    let id: UUID
    let workoutType: WorkoutType?
    let date: Date?
    let type: MeasureUnit = .heartRate

    let value: Double
}
