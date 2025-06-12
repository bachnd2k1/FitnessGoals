//
//  WatchWorkoutViewModel.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 9/6/25.
//

import Foundation
import Combine

import CoreLocation

@MainActor
class WatchWorkoutViewModel: ObservableObject {
    private let motionManager = MotionManager()
    private let watchsessionManager = WatchSessionManager.shared
    private let predictor = WorkoutPredictor()
    private let heartRateMonitor = HeartRateMonitor()
    private let sessionTimer = TimerManager()
    
    @Published var distance: Distance?
    @Published var speed: Speed?
    @Published var steps: Step?
    @Published var calories: Calorie?
    @Published var currentHeartRate: HeartRate?
    @Published var startDate: Date?
    @Published private var isStartingWorkout = false
    @Published var workoutStarted: Bool = false
    @Published var state: TimerMode?
    @Published var elapsedTime: TimeInterval = 10
    @Published var timerIsNil: Bool = true
    @Published var didCancelWorkout: Bool = false
    @Published var totalElapsedTime: TimeInterval = 0
    
    @Published var isPreparing = true
    @Published var countdown = 5
    @Published var showCountdownView = false
    
    var timerIsPaused: Bool { state == .paused }
    var workoutType: WorkoutType?
    private var workoutId: UUID = UUID()
    private var isPaused = false
    
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(router: WatchNavigationRouter, type: WorkoutType?) {
        self.workoutType = type
        //        router.$latestMeasurement
        //                    .compactMap { $0 }
        //                    .sink { [weak self] measurement in
        //                        self?.receiveNewMeasurement(measurement)
        //                    }
        //                    .store(in: &cancellables)
        
        router.measurementPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] measurement in
                guard let self  else { return }
                // Lưu lại hoặc xử lý measurement
                self.receiveNewMeasurement(measurement)
            }
            .store(in: &cancellables)
        setupBindings()
    }
    
    private func setupBindings() {
        sessionTimer.$isNil.assign(to: &$timerIsNil)
        
        sessionTimer.$state
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
        
        sessionTimer.$elapsedTime
            .receive(on: DispatchQueue.main)
            .assign(to: \.elapsedTime, on: self)
            .store(in: &cancellables)
        
        $elapsedTime
            .sink { [weak self] elapsedTime in
                if let self, let startDate, elapsedTime > 0 {
                    if let workoutType, workoutType != .cycling {
                        let accel = self.motionManager.currentAccelerationMagnitude()
                        self.motionManager.getSteps(startDate: startDate, endDate: startDate + elapsedTime)
                        self.predictor.predict(accel: accel)
                        self.updateUIFromPredictor()
                    }
                }
            }
            .store(in: &cancellables)
        
        
        motionManager.$steps
            .sink { [weak self] stepValue in
                if let self {
                    
                }
            }
            .store(in: &cancellables)
        
        
        //        Timer.publish(every: 1.0, on: .main, in: .common)
        //            .autoconnect()
        //            .sink { [weak self] _ in
        //                guard let self else { return }
        //                let accel = self.motionManager.currentAccelerationMagnitude()
        //                let steps = self.motionManager.getSteps(startDate: startDate, endDate: startDate + elapsedTime)
        //                self.predictor.predict(accel: accel)
        //                self.updateUIFromPredictor()
        //            }
        //            .store(in: &cancellables)
        
        //        Timer.publish(every: 5.0, on: .main, in: .common)
        //            .autoconnect()
        //            .handleEvents(receiveOutput: { print("⏱ Timer emitted: \($0)") })
        //            .combineLatest(heartRateMonitor.$currentHeartRate
        //                .handleEvents(receiveOutput: { print("❤️ HeartRate changed: \($0)") }))
        //            .sink { [weak self] (_, currentHeartRate) in
        //                guard let self else { return }
        //                print("🚀 Sending heart rate: \(currentHeartRate)")
        ////                self.currentHeartRate = HeartRate(id: UUID(),
        ////                                                  workoutType: workoutType,
        ////                                                  date: self.startDate,
        ////                                                  value: currentHeartRate)
        //                self.watchsessionManager.sendHeartHeartRate(currentHeartRate)
        //            }
        //            .store(in: &cancellables)
        
        
        heartRateMonitor.$currentHeartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentHeartRate in
                guard let self else { return }
                print("🚀 Current heart rate: \(currentHeartRate)")
                self.currentHeartRate = HeartRate(id: self.workoutId,
                                                  workoutType: self.workoutType,
                                                  date: self.startDate, value: currentHeartRate)
            }
            .store(in: &cancellables)
        
        $isStartingWorkout
            .sink { [weak self] isStartingWorkout in
                guard let self = self else { return }
                if isStartingWorkout {
                    self.startDate = Date()
                    self.workoutStarted = true
                    sessionTimer.start()
                }
            }
            .store(in: &cancellables)
        
        $elapsedTime
            .sink { [weak self] elapsedTime in
                if let self, let startDate, elapsedTime > 0 {
                    if let workoutType, workoutType != .cycling {
                        //                        self.motionManager.getSteps(startDate: startDate, endDate: startDate + elapsedTime)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func startWorkout() {
        isStartingWorkout = true
        guard let workoutType = workoutType else { return }
        predictor.setWorkoutType(type: workoutType)
    }
    
    func pauseWorkout() {
        watchsessionManager.pauseWorkout()
        sessionTimer.pause()
        isPaused = true
        heartRateMonitor.pauseWorkoutSession()
    }
    
    func resumeWorkout() {
        watchsessionManager.resumeWorkout()
        sessionTimer.resume()
        isPaused = false
        heartRateMonitor.resumeWorkoutSession()
    }
    
    func endWorkout() {
        watchsessionManager.endWorkout()
        totalElapsedTime = elapsedTime
        heartRateMonitor.stopWorkoutSession()
        sessionTimer.stop()
        didCancelWorkout = true
        isStartingWorkout = false
    }
    
    func receiveNewMeasurement(_ m: WorkoutMeasurement) {
        predictor.correct(with: m)
        updateUIFromPredictor()
    }
    
    private func updateUIFromPredictor() {
        let state = predictor.state
        let now = Date()
        self.distance = Distance(id: workoutId, workoutType: workoutType, date: now, measure: Measurement(value: state.distance, unit: .meters))
        self.speed = Speed(id: workoutId, workoutType: workoutType, date: now, measure: Measurement(value: state.speed, unit: .kilometersPerHour))
        self.steps = Step(id: workoutId, workoutType: workoutType, date: now, count: state.steps)
        self.calories = Calorie(id: workoutId, workoutType: workoutType, date: now, count: state.calories)
    }
    
    func startCountdown() {
        if let workoutType = self.workoutType {
            isPreparing = true
            self.watchsessionManager.startWorkout(type: workoutType)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Task { @MainActor in
                self.heartRateMonitor.startWorkoutSession()
                self.showCountdownView = true
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    Task { @MainActor in
                        if self.countdown > 0 {
                            self.countdown -= 1
                        } else {
                            self.isPreparing = false
                            self.showCountdownView = false
                            self.countdown = 0
                            timer.invalidate()
                            self.startWorkout()
                        }
                    }
                }
            }
        }
    }
}
