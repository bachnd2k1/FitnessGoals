//
//  FitnessAttributes.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/3/25.
//

import Foundation
import ActivityKit

struct FitnessAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var elapsedTime: String
        var steps: Int
        var distance: String
        var speed: String
        var icon: String
        var isPaused: Bool
    }
    
    var workoutType: String
    
    static var preview: FitnessAttributes {
        FitnessAttributes(workoutType: "Running")
    }
}
