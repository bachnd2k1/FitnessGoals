//
//  MeasureUnit.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

enum MeasureUnit: Int16, CaseIterable {
    case distance
    case speed
    case step
    case calorie
    case heartRate

    var name: String {
        switch self {
        case .distance: return "Distance"
        case .speed: return "Speed"
        case .step: return "Steps"
        case .calorie: return "Calories"
        case .heartRate: return "Heart Rate"
        }
    }
    
    var unitOfMeasure: String {
        switch self {
        case .distance: return "km"
        case .speed: return "km/h"
        case .step: return "steps"
        case .calorie: return "kcal"
        case .heartRate: return "bpm"
        }
    }

    var icon: String {
        switch self {
        case .distance: return "road.lanes"
        case .speed: return "speedometer"
        case .step: return "shoeprints.fill"
        case .calorie: return "scalemass"
        case .heartRate: return "scalemass"
        }
    }
}
