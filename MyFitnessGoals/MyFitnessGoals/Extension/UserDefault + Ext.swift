//
//  UserDefault + Ext.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 03/02/2025.
//

import Foundation

extension UserDefaults {
    enum Keys: String {
        case distance
        case calories
        case steps
    }
    
    static func setDefaultValues() {
        let defaults = UserDefaults.standard
        
        // Set default values if they haven't been set before
        if !defaults.contains(key: .distance) {
            defaults.set(5.0, forKey: Keys.distance.rawValue) // Default 5km
        }
        
        if !defaults.contains(key: .calories) {
            defaults.set(500, forKey: Keys.calories.rawValue) // Default 500 calories
        }
        
        if !defaults.contains(key: .steps) {
            defaults.set(1000, forKey: Keys.steps.rawValue) // Default 10000 steps
        }
    }
    
    private func contains(key: Keys) -> Bool {
        return object(forKey: key.rawValue) != nil
    }
}
