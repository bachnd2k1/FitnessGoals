//
//  WelcomeFlow.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import Foundation
import SwiftUI

struct WelcomeFlow: View {
    @State private var currentStep: StepOnboarding = .welcome
    @StateObject private var viewModel = WelcomeFlowViewModel(healthKitManager: HealthKitManager.shared)
    @AppStorage("hasFinishedSetup") var hasFinishedSetup: Bool = false
    @AppStorage("onboardingStarted") var onboardingStarted: Bool = false
    @AppStorage("onboardingCompleted") var onboardingCompleted: Bool = false

    var body: some View {
        VStack {
            switch currentStep {
            case .welcome:
                WelcomeView(onNext: goNext)
            case .fillInfo:
                FillInfoView { age, gender, weight, height  in
                    viewModel.saveUserInfo(age: age, gender: gender, weight: weight, height: height)
                    goNext()
                }
//            case .requestHealth:
//                RequestPermissionView(viewModel: viewModel, permission:.health ,onNext: goNext)
            case .requestLocation:
                RequestPermissionView(viewModel: viewModel, permission:.location ,onNext: goNext)
            case .requestMotion:
                RequestPermissionView(viewModel: viewModel, permission:.motion ,onNext: completeSetup)
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: currentStep)
        .transition(.slide)
    }

    func goNext() {
        if currentStep == .welcome {
            onboardingStarted = true // bắt đầu onboarding
        }
        currentStep = StepOnboarding(rawValue: currentStep.rawValue + 1) ?? .welcome
    }

    func completeSetup() {
        onboardingCompleted = true
        hasFinishedSetup = true
    }
}

#Preview {
    WelcomeFlow()
}
