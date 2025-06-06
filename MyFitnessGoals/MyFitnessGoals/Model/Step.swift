//
//  Step.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

struct Step: BaseFitnessModel, Hashable {
    let id: UUID
    let workoutType: WorkoutType?
    let date: Date?
    let type: MeasureUnit = .step
    let count: Int

    var value: Double {
        Double(count)
    }
    
    func getStep() -> Int {
        return Int(count)
    }
    
    var valueString: String {
        String(Int(count))
    }
}
