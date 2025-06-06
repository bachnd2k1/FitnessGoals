//
//  BaseFitnessModel.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

protocol BaseFitnessModel {
    var id: UUID { get }
    var workoutType: WorkoutType? { get }
    var date: Date? { get }
    var type: MeasureUnit { get }
    var value: Double { get }
}
