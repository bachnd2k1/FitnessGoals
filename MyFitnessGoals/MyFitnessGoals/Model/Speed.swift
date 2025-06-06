//
//  Speed.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

struct Speed: BaseFitnessModel, Hashable {
    let id: UUID
    let workoutType: WorkoutType?
    let date: Date?
    let type: MeasureUnit = .speed
    let measure: Measurement<UnitSpeed>

    var value: Double {
        measure.converted(to: .kilometersPerHour).value
    }
}
