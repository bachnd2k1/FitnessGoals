//
//  PageView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 2/5/25.
//

import SwiftUI

struct PageView: View {
    @ObservedObject var viewModel: RecordWorkViewModel
    //    @ObservedObject var viewModel: WorkoutViewModel
    @State private var countdown = 5
    
    var body: some View {
        VStack {
            if viewModel.locationAccessIsDenied {
                Text("Location access is denied")
            } else {
                TabView {
                    if viewModel.isPreparing {
                        CountdownTimerView(
                            count: viewModel.countdown,
                            totalCount: countdown,
                            showCountdownView: viewModel.showCountdownView
                        )
                    } else {
                        TutorialView(viewModel: viewModel)
                    }
                    RecordWorkView(viewModel: viewModel)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onAppear {
//                    viewModel.startWorkout()
//                    viewModel.startCountdown()
//                    viewModel.startCountdown(after: 3)
                    viewModel.startCountdown()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.requestPermisson()
        }
    }
}

#Preview {
    PageView(viewModel: RecordWorkViewModel(dataManager: .preview, type: .cycling, healthKitManager: .shared))
}
