
//
//  RecordWorkoutView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI

struct RecordWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @EnvironmentObject var router: MobileNavigationRouter
    let workoutType: WorkoutType
    
    @State private var showAlert = false
    @State private var timerIsStopped = false
    @State private var finishedWorkout = false
    @State private var isFullScreenMap = false
    @State private var isCancelWorkout = false
    
    @State private var countdown = 5
    @EnvironmentObject var themeManager: ThemeManager
    
    
    init(workoutType: WorkoutType, viewModel: WorkoutViewModel) {
        self.workoutType = workoutType
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Group {
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
                            //                        if viewModel.motionAccessIsDenied {
                            //                            Spacer()
                            //                            DeniedPermissionView()
                            //                        }
                            Spacer()
                            if !isFullScreenMap {
                                TimerView(
                                    viewModel: viewModel,
                                    errorLocationIsThrown: $viewModel.locationAccessThrowsError,
                                    locationAccessIsDenied: $viewModel.locationAccessIsDenied,
                                    errorMocationIsThrown: $viewModel.motionAccessThrowsError,
                                    motionAccessIsDenied: $viewModel.motionAccessIsDenied,
                                    elapsedTime: viewModel.elapsedTime,
                                    timerIsNil: viewModel.timerIsNil,
                                    timerIsPaused: viewModel.timerIsPaused
                                ) {
                                    if viewModel.hasLocationPermission && viewModel.hasMotionPermission {
                                        viewModel.startCountdown()
                                    } else {
                                        viewModel.requestPermisson()
                                    }
                                } pauseAction: {
                                    viewModel.pauseWorkout()
                                } resumeAction: {
                                    timerIsStopped = false
                                    viewModel.resumeWorkout()
                                } stopAction: {
                                    timerIsStopped = true
                                    viewModel.pauseWorkout()
                                }
                                .alert(L10n.warning, isPresented: $timerIsStopped) {
                                    Button(L10n.yes) {
                                        viewModel.endWorkout()
                                        viewModel.addWorkout()
                                        router.shouldEndWorkout = true
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
                                    router.cancelWorkoutThroughWatchCall()
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
            .navigationDestination(item: $router.finishedWorkout) { workout in
                DetailHistoryView(workout: workout, viewModel: HistoryViewModel(), themeManager: _themeManager)
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
                router.endWorkoutThroughWatchCall()
                let workout = viewModel.getWorkoutCoreData() // addWorkout giờ sẽ trả về Workout vừa hoàn thành
                router.finishedWorkout = workout
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
        .onChange(of: router.finishedWorkout) { _, currentWorkout in
            if currentWorkout == nil {
                // Khi user ấn back từ màn Detail
                router.currentWorkoutType = nil // → đóng RecordWorkoutView
            }
        }
    }
}

struct RecordWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = WorkoutViewModel(dataManager: .preview, type: nil, healthKitManager: .shared, workoutSessionManager: WorkoutSessionManager.shared)
        RecordWorkoutView(workoutType: .running, viewModel: vm)
            .environmentObject(MobileNavigationRouter())
    }
}
