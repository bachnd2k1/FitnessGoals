//
//  WorkoutViewModel.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 2/5/25.
//

import Combine
import Foundation
import CoreLocation

@MainActor
class RecordWorkViewModel: ObservableObject {
    private let locationManager = LocationManager()
    private let sessionTimer = TimerManager()
    private let motionManager = MotionManager()
    private let dataManager: CoreDataManager
    private let healthKitManager: HealthKitManager
    private let heartRateMonitor = HeartRateMonitor()
    private let watchsessionManager: WatchSessionManager = WatchSessionManager.shared
    
    
    @Published var state: TimerMode?
    @Published var elapsedTime: TimeInterval = 0
    @Published var timerIsNil: Bool = true
    @Published var workoutStarted: Bool = false
    @Published var startDate: Date?
    @Published var distance: Distance?
    @Published var speed: Speed?
    @Published var currentHeartRate: HeartRate?
    
    @Published var route: [CLLocation] = []
    var startLocation: CLLocation? { route.first }
    @Published var endLocation: CLLocation?
    @Published var steps: Step?
    @Published var calories: Calorie?
    @Published var totalElapsedTime: TimeInterval = 0
    @Published var locationAccessIsDenied: Bool = false
    @Published var locationAccessNotDetermine: Bool = false
    @Published var locationAccessThrowsError: Bool = false
    @Published var locationAccessError = ""
    @Published var didCancelWorkout: Bool = false
    @Published var isAllowMotion: Bool = false
    
    @Published var motionAccessIsDenied: Bool = false
    @Published var motionAccessThrowsError: Bool = false
    
    @Published var isPreparing = true
    @Published var countdown = 5
    @Published var showCountdownView = false
    @Published private var isStartingWorkout = false
    
    var totalCount: Int = 3
    var startAt: Date?
    
    
    var timerIsPaused: Bool { state == .paused }
    
    var workoutType: WorkoutType?
    private var workoutId: UUID = UUID()
    
    private var cancellables: Set<AnyCancellable> = []
    private var isPaused = false
    private var prepareTimer: Timer?
    
    init(dataManager: CoreDataManager, type: WorkoutType?, healthKitManager: HealthKitManager) {
        self.dataManager = dataManager
        self.workoutType = type
        self.healthKitManager = healthKitManager
        
        setupBindings()
    }
    
    
    private func setupBindings() {
        locationManager.$locations.assign(to: &$route)
        locationManager.$endLocation.assign(to: &$endLocation)
        locationManager.$locationAccessIsDenied.assign(to: &$locationAccessIsDenied)
        locationManager.$locationAccessThrowsError.assign(to: &$locationAccessThrowsError)
        locationManager.$locationAccessError.assign(to: &$locationAccessError)
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
        
        
        
        locationManager.distancePublisher
            .sink { [weak self] distanceValue in
                if let self {
                    self.distance = Distance(
                        id: self.workoutId,
                        workoutType: self.workoutType,
                        date: self.startDate,
                        measure: distanceValue
                    )
                }
            }
            .store(in: &cancellables)
        
        locationManager.speedPublisher
            .sink { [weak self] speedValue in
                if let self {
                    self.speed = Speed(
                        id: self.workoutId,
                        workoutType: self.workoutType,
                        date: self.startDate,
                        measure: speedValue
                    )
                }
            }
            .store(in: &cancellables)
        
        $elapsedTime
            .sink { [weak self] elapsedTime in
                if let self, let startDate, elapsedTime > 0 {
                    if let workoutType, workoutType != .cycling {
                        self.motionManager.getSteps(startDate: startDate, endDate: startDate + elapsedTime)
                    }
                }
            }
            .store(in: &cancellables)
        
        motionManager.$steps
            .sink { [weak self] stepValue in
                if let self {
                    self.steps = Step(
                        id: self.workoutId,
                        workoutType: self.workoutType,
                        date: self.startDate,
                        count: stepValue ?? 0
                    )
                }
            }
            .store(in: &cancellables)
        
        //        motionManager.$isAuthorizeMotion
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] isAuthorizeMotion in
        //                guard let self else {
        //                    return
        //                }
        ////                self.isAllowMotion = isAllowMotion
        //                if let isAuthorizeMotion = isAuthorizeMotion {
        //                    if isAuthorizeMotion && isStartingWorkout {
        //                        self.locationManager.endLocation = nil
        //                        self.startDate = Date()
        //                        self.workoutStarted = true
        //                        sessionTimer.start()
        //                        self.locationManager.startLocationServices()
        //                        self.heartRateMonitor.startWorkoutSession()
        //                    }
        //                    self.motionAccessIsDenied = !isAuthorizeMotion
        //                }
        //            }
        //            .store(in: &cancellables)
        
        // check to start timer session
        $isStartingWorkout
            .sink { [weak self] isStartingWorkout in
                guard let self = self else { return }
                if isStartingWorkout {
                    self.locationManager.endLocation = nil
                    self.startDate = Date()
                    self.workoutStarted = true
                    sessionTimer.start()
                }
            }
            .store(in: &cancellables)
        
        healthKitManager.$isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthorizeHealthKit in
                guard let self else { return }
            }
            .store(in: &cancellables)
        
        //        heartRateMonitor.$currentHeartRate
        //            .receive(on: DispatchQueue.main)
        //            .sink { [weak self] currentHeartRate in
        //                guard let self else { return }
        //                self.currentHeartRate = HeartRate(id: self.workoutId,
        //                                                  workoutType: self.workoutType,
        //                                                  date: self.startDate, value: currentHeartRate)
        //            }
        //            .store(in: &cancellables)
        
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .handleEvents(receiveOutput: { print("⏱ Timer emitted: \($0)") })
            .combineLatest(heartRateMonitor.$currentHeartRate
                .handleEvents(receiveOutput: { print("❤️ HeartRate changed: \($0)") }))
            .sink { [weak self] (_, currentHeartRate) in
                guard let self else { return }
                print("🚀 Sending heart rate: \(currentHeartRate)")
                self.currentHeartRate = HeartRate(id: self.workoutId,
                                                  workoutType: self.workoutType,
                                                  date: self.startDate,
                                                  value: currentHeartRate)
                self.watchsessionManager.sendHeartHeartRate(currentHeartRate)
            }
            .store(in: &cancellables)
        
    }
    
    func startWorkout() {
        isStartingWorkout = true
    }
    
    func pauseWorkout() {
        watchsessionManager.pauseWorkout()
        sessionTimer.pause()
        isPaused = true
        locationManager.stopLocationServices()
        heartRateMonitor.pauseWorkoutSession()
    }
    
    func resumeWorkout() {
        watchsessionManager.resumeWorkout()
        sessionTimer.resume()
        isPaused = false
        locationManager.startLocationServices()
        heartRateMonitor.resumeWorkoutSession()
    }
    
    func endWorkout() {
        watchsessionManager.endWorkout()
        totalElapsedTime = elapsedTime
        locationManager.stopLocationServices()
        heartRateMonitor.stopWorkoutSession()
        getMetrics()
        sessionTimer.stop()
        didCancelWorkout = true
        isStartingWorkout = false
    }
    
    private func getMetrics() {
        let totalDistance = locationManager.totalDistance
        distance = Distance(
            id: workoutId,
            workoutType: workoutType,
            date: startDate,
            measure: Measurement(value: totalDistance, unit: .meters)
        )
        
        let averageSpeed = totalDistance / elapsedTime
        speed = Speed(
            id: workoutId,
            workoutType: workoutType,
            date: startDate,
            measure: Measurement(value: averageSpeed, unit: .metersPerSecond)
        )
        
        var caloriesCount = 0
        switch workoutType {
        case .running:
            caloriesCount = Int(totalDistance / 1000 * 70)
        case .walking:
            caloriesCount = Int(totalDistance / 1000 * 55)
        case .cycling:
            caloriesCount = Int(totalDistance / 1000 * 25)
        case nil:
            break
        }
        
        calories = Calorie(
            id: workoutId,
            workoutType: workoutType,
            date: startDate,
            count: caloriesCount
        )
    }
    
    func requestPermisson() {
        healthKitManager.requestAuthorization()
        locationManager.requestPermission()
        motionManager.requestMotionPermission()
    }
    
    
    func startCountdown() {
        if let workoutType = self.workoutType {
            isPreparing = true
            self.watchsessionManager.startWorkout(type: workoutType)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Task { @MainActor in
                self.heartRateMonitor.startWorkoutSession()
                self.locationManager.startLocationServices()
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
    
    
    //    func startCountdown() {
    //        countdown = totalCount
    //
    //        cancellable = Timer
    //            .publish(every: 1, on: .main, in: .common) // chạy trên main thread
    //            .autoconnect()
    //            .sink { [weak self] _ in
    //                guard let self = self else { return }
    //
    //                if self.countdown > 1 {
    //                    self.countdown -= 1
    //                } else {
    //                    self.countdown = 0
    //                    self.cancellable?.cancel()
    //                    self.startWorkout()
    //                }
    //            }
    //    }
}
