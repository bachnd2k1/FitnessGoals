//
//  AppEntryView.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import SwiftUI

struct AppEntryView: View {
    @AppStorage("hasFinishedSetup") var hasFinishedSetup: Bool = false
    @AppStorage("onboardingStarted") var onboardingStarted: Bool = false
    @AppStorage("onboardingCompleted") var onboardingCompleted: Bool = false

    private let dataManager: CoreDataManager = .shared
    @StateObject private var themeManager = ThemeManager()
    @StateObject var router = MobileNavigationRouter()

    @State private var isReadyToRender = false

    var body: some View {
        Group {
            if isReadyToRender {
                ZStack {
                    if hasFinishedSetup {
                        NavigationStack {
                            TabBarView(dataManager: dataManager)
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
            } else {
                Color.clear
            }
        }
        .environmentObject(router)
        .environmentObject(themeManager)
        .onAppear {
            if onboardingStarted && !onboardingCompleted {
                hasFinishedSetup = true
            }

            // Cho render sau 1 "run loop" để hasFinishedSetup cập nhật xong
            // Khi đang onboarding mà thoát thì sẽ exit flow luôn
            DispatchQueue.main.async {
                isReadyToRender = true
            }
        }
    }
}

#Preview {
    AppEntryView()
}
