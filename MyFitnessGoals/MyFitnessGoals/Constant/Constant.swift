//
//  Constant.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation

public class Constant {
    enum Tab: String {
        case workout = "figure.run"
        case history = "clock.arrow.circlepath"
        case statistics = "chart.xyaxis.line"
        case goals = "target"

        var tabName: String {
            switch self {
            case .workout: return "Workout"
            case .history: return "History"
            case .statistics: return "Statistics"
            case .goals: return "Goals"
            }
        }
    }
}
