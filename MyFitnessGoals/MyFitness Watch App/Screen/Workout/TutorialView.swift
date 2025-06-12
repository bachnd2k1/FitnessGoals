//
//  TurtorialView.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 2/5/25.
//

import SwiftUI

struct TutorialView: View {
    @ObservedObject var viewModel: RecordWorkViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Control Buttons
                HStack {
                    ButtonActionView(
                        icon: viewModel.timerIsPaused ? "play.fill" : "pause.fill",
                        label: viewModel.timerIsPaused ? "Resume" : "Pause",
                        action: {
                            if viewModel.timerIsPaused {
                                viewModel.resumeWorkout()
                            } else {
                                viewModel.pauseWorkout()
                            }
                        }
                    )
                    
                    Spacer()
                    
                    ButtonActionView(icon: "stop.fill", label: "Stop", action: {
                        viewModel.endWorkout()
                    })
                    
                }
                .padding(8)
                .background(.gray.opacity(0.5))
                .cornerRadius(12)
                
                // Tutorial Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Workout control")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack {
                        ZStack {
                            Image("ic_apple_watch1")
                            HStack {
                                Spacer()
                                VStack(spacing: 20) {
                                    Image(systemName: "arrow.right")
                                        .scaleEffect(x: -1, y: 1)
                                        .foregroundColor(.white)
                                    Image(systemName: "arrow.right")
                                        .scaleEffect(x: -1, y: 1)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        Text("Press both controls at the same time to pause or resume a workout.")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                    .padding(10)
                    .background(.gray.opacity(0.5))
                    .cornerRadius(12)
                }
            }
            .padding() // Ensure consistent padding
        }
        .padding(.top, 8)
        .ignoresSafeArea()
        .background(Color.black.edgesIgnoringSafeArea(.all)) // Or your background color
        
    }
}

#Preview {
    TutorialView(viewModel: RecordWorkViewModel(dataManager: .preview, type: .cycling, healthKitManager: .shared, router: WatchNavigationRouter()))
}
