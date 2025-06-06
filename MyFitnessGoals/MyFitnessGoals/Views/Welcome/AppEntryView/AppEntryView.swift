//
//  AppEntryView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct AppEntryView: View {
    @AppStorage("hasFinishedSetup") var hasFinishedSetup: Bool = false
    private let dataManager: CoreDataManager = .shared
    @StateObject private var themeManager = ThemeManager()
    @StateObject var router = NavigationRouter()
    
    var body: some View {
        ZStack {
            if hasFinishedSetup {
                NavigationStack {
                    TabBarView(dataManager: dataManager)
                        .environmentObject(router)
                        .environmentObject(themeManager)
                        .onAppear {
                            let workoutSessionManager = WorkoutSessionManager.shared
                            workoutSessionManager.configure(router: router)
                        }
                }
            } else {
                WelcomeFlow()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: hasFinishedSetup)
    }
}

#Preview {
    AppEntryView()
}
