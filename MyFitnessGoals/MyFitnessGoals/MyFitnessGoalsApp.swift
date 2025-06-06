//
//  MyFitnessGoalsApp.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import SwiftUI

@main
struct MyFitnessGoalsApp: App {
    init() {
        UserDefaults.setDefaultValues()
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
        }
    }
}
