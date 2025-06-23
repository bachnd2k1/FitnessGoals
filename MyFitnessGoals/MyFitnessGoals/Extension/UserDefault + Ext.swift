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
        case age
        case gender
        case weight
        case height
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
    
    func save<T>(_ value: T?, for key: Keys) {
        guard let value = value else {
            removeObject(forKey: key.rawValue)
            return
        }
        
        switch value {
        case let v as Int:
            set(v, forKey: key.rawValue)
        case let v as Double:
            set(v, forKey: key.rawValue)
        case let v as Float:
            set(v, forKey: key.rawValue)
        case let v as Bool:
            set(v, forKey: key.rawValue)
        case let v as String:
            set(v, forKey: key.rawValue)
        default:
            print("Unsupported type for UserDefaults key: \(key.rawValue)")
        }
    }
    
    func get<T>(_ type: T.Type, for key: Keys) -> T? {
        return object(forKey: key.rawValue) as? T
    }
    
    func getInt(for key: Keys) -> Int? {
        let value = object(forKey: key.rawValue) as? Int
        return value
    }
    
    func getDouble(for key: Keys) -> Double? {
        let value = object(forKey: key.rawValue) as? Double
        return value
    }
    
    func getString(for key: Keys) -> String? {
        return string(forKey: key.rawValue)
    }
}
