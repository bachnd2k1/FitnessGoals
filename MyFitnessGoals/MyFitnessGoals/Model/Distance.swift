//
//  Distance.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

struct Distance: BaseFitnessModel, Hashable {
    let id: UUID
    let workoutType: WorkoutType?
    let date: Date?
    let type: MeasureUnit = .distance
    let measure: Measurement<UnitLength>

    var value: Double {
        measure.converted(to: .kilometers).value
    }
}
