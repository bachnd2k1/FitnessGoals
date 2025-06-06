//
//  WelcomeFlow.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import Foundation
import SwiftUI

struct WelcomeFlow: View {
    @State private var currentStep = 0
    @StateObject private var viewModel = WelcomeFlowViewModel(healthKitManager: HealthKitManager.shared)
    @AppStorage("hasFinishedSetup") var hasFinishedSetup: Bool = false

    var body: some View {
        VStack {
            switch currentStep {
            case 0:
                WelcomeView(onNext: goNext)
            case 1:
                FillInfoView(onNext: goNext)
            case 2:
                RequestPermissionView(viewModel: viewModel, permission:.health ,onNext: goNext)
            case 3:
                RequestPermissionView(viewModel: viewModel, permission:.location ,onNext: goNext)
            case 4:
                RequestPermissionView(viewModel: viewModel, permission:.motion ,onNext: completeSetup)
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut, value: currentStep)
        .transition(.slide)
    }

    func goNext() {
        currentStep += 1
    }

    func completeSetup() {
        hasFinishedSetup = true
    }
}

#Preview {
    WelcomeFlow()
}
