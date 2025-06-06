//
//  WorkoutType.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

enum WorkoutType: Int16, CaseIterable, Identifiable {
    var id: Int16 { rawValue }
    
    case running
    case walking
    case cycling

    var name: String {
        switch self {
        case .running: return "Running"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        }
    }

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        }
    }
    var banner: String {
        switch self {
        case .running: return "runningBanner"
        case .walking: return "walkingBanner"
        case .cycling: return "cyclingBanner"
        }
    }
    var background: String {
        switch self {
        case .running: return "runningBackground"
        case .walking: return "walkingBackground"
        case .cycling: return "cyclingBackground"
        }
    }
}
