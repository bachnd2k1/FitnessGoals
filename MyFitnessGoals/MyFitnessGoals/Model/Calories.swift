//
//  Calories.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

struct Calorie: BaseFitnessModel, Hashable {
    let id: UUID
    let workoutType: WorkoutType?
    let date: Date?
    let type: MeasureUnit = .calorie
    let count: Int

    var value: Double {
        Double(count)
    }
}
