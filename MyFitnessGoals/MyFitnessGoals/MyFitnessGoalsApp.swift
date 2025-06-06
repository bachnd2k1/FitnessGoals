//
//  MyFitnessGoalsApp.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import SwiftUI

@main
struct MyFitnessGoalsApp: App {
//    private let dataManager: CoreDataManager = .shared
//    @StateObject private var themeManager = ThemeManager()
//    @StateObject var router = NavigationRouter()
    
    init() {
        UserDefaults.setDefaultValues()
    }
    
    var body: some Scene {
        WindowGroup {
            AppEntryView()
//            NavigationStack {
//                TabBarView(dataManager: dataManager)
//                    .environmentObject(router)
//                    .environmentObject(themeManager)
//                    .onAppear {
//                        let workoutSessionManager = WorkoutSessionManager.shared
//                        workoutSessionManager.configure(router: router)
//                    }
//            }
        }
    }
}
