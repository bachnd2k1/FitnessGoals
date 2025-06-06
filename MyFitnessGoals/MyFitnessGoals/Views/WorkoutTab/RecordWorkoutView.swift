
//
//  RecordWorkoutView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct RecordWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var router: NavigationRouter
    //    @Binding var workoutType: WorkoutType?
    let workoutType: WorkoutType
    
    @State private var showAlert = false
    @State private var timerIsStopped = false
    @State private var finishedWorkout = false
    @State private var isFullScreenMap = false
    @State private var isCancelWorkout = false
    //    @State private var shouldStartImmediately: Bool
    
    @State private var countdown = 5
    
    
    init(workoutType: WorkoutType, viewModel: WorkoutViewModel) {
        //        self._workoutType = workoutType
        self.workoutType = workoutType
        self.viewModel = viewModel
        //        self.viewModel = WorkoutViewModel(
        //            dataManager: .shared,
        //            type: workoutType,
        //            healthKitManager: .shared
        //        )
        //        _viewModel = .init(wrappedValue: WorkoutViewModel(dataManager: .shared, type: workoutType.wrappedValue, healthKitManager: .shared))
        
        
        //        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.isPreparing {
                CountdownTimerView(count: viewModel.countdown, totalCount: countdown, showCountdownView: viewModel.showCountdownView)
            } else {
                ZStack {
                    Image(workoutType.background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                    
                    VStack {
                        if !isFullScreenMap {
                            Image(workoutType.icon)
                                .font(.system(size: 60))
                                .padding(.bottom, 5)
                                .foregroundStyle(.white)
                        }
                        if !viewModel.locationAccessIsDenied && !viewModel.locationAccessThrowsError {
                            if viewModel.workoutStarted {
                                Group {
                                    MapView(mapType: .moving,
                                            startLocation: viewModel.startLocation,
                                            route: viewModel.route,
                                            endLocation: viewModel.endLocation,
                                            isFullScreen: $isFullScreenMap
                                    )
                                }
                            }
                        }
                        if viewModel.motionAccessIsDenied {
                            Spacer()
                            DeniedPermissionView()
                        }
                        Spacer()
                        if !isFullScreenMap {
                            TimerView(
                                viewModel: viewModel,
                                errorIsThrown: $viewModel.locationAccessThrowsError,
                                accessIsDenied: $viewModel.motionAccessIsDenied,
                                elapsedTime: viewModel.elapsedTime,
                                timerIsNil: viewModel.timerIsNil,
                                timerIsPaused: viewModel.timerIsPaused
                            ) {
                                if (!viewModel.locationAccessIsDenied && !viewModel.locationAccessThrowsError)
                                    ||
                                    (!viewModel.motionAccessIsDenied && viewModel.motionAccessThrowsError) {
                                    viewModel.startCountdown()
                                } else {
                                    viewModel.requestPermisson()
                                }
                            } pauseAction: {
                                viewModel.pauseWorkout()
                            } resumeAction: {
                                viewModel.resumeWorkout()
                            } stopAction: {
                                timerIsStopped = true
                                viewModel.pauseWorkout()
                            }
                            .alert(L10n.warning, isPresented: $timerIsStopped) {
                                Button(L10n.yes) {
                                    viewModel.endWorkout()
                                    router.currentWorkoutType = nil
                                    viewModel.addWorkout()
                                }
                                Button(L10n.no, role: .cancel) {}
                            } message: {
                                Text(L10n.endSessionTitleDialog)
                            }
                        }
                    }
                }
                .onChange(of: viewModel.locationAccessError) {
                    showAlert = viewModel.locationAccessThrowsError
                }
                .onChange(of: viewModel.didCancelWorkout) {
                    if viewModel.didCancelWorkout {
                        router.currentWorkoutType = nil
                        router.endWorkoutThroughWatchCall()
                    }
                }
                .alert(L10n.locationError, isPresented: $showAlert) {
                    Button(L10n.ok, role: .cancel) {}
                } message: {
                    Text(viewModel.locationAccessError)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if !viewModel.isStartingWorkout {
                                router.currentWorkoutType = nil
                            } else {
                                isCancelWorkout = true
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        }
                        .opacity(isFullScreenMap ? 0 : 1)
                        .alert(L10n.warning, isPresented: $isCancelWorkout) {
                            Button(L10n.yes) {
                                viewModel.cancelWorkout()
                                //                            workoutType = nil
                                router.currentWorkoutType = nil
                                router.endWorkoutThroughWatchCall()
                            }
                            Button(L10n.no, role: .cancel) {
                                isCancelWorkout = false
                            }
                        } message: {
                            Text(L10n.cancelSessionTitleDialog)
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
        .onChange(of: router.shouldPauseWorkout) {
            if router.shouldPauseWorkout  {
                viewModel.pauseWorkout()
                router.shouldPauseWorkout = false // Reset trigger
            }
        }
        .onChange(of: router.shouldResumeWorkout) {
            if router.shouldResumeWorkout {
                viewModel.resumeWorkout()
                router.shouldResumeWorkout = false // Reset trigger
            }
        }
        .onChange(of: router.shouldEndWorkout) {
            if router.shouldEndWorkout {
                timerIsStopped = true
                //                viewModel.endWorkout()
                //                router.shouldEndWorkout = false
                viewModel.endWorkout()
                router.currentWorkoutType = nil
                viewModel.addWorkout()
                router.shouldEndWorkout = false // Reset trigger
            }
        }
        .onAppear {
            if router.shouldStartImmediately {
                DispatchQueue.main.async {
                    if !viewModel.locationAccessIsDenied &&
                        !viewModel.locationAccessThrowsError &&
                        !viewModel.workoutStarted {
                        viewModel.startCountdown(delay: router.delayTime)
                    }
                }
            }
        }
    }
}

struct RecordWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = WorkoutViewModel(dataManager: .preview, type: nil, healthKitManager: .shared)
        RecordWorkoutView(workoutType: .running, viewModel: vm)
            .environmentObject(NavigationRouter())
    }
}
