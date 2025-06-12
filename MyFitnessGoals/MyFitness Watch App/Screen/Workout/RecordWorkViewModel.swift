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
    private let predictor = WorkoutPredictor()
    
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
    var isPaired: Bool = false
    
    var timerIsPaused: Bool { state == .paused }
    
    var workoutType: WorkoutType?
    private var workoutId: UUID = UUID()
    
    private var cancellables: Set<AnyCancellable> = []
    private var isPaused = false
    private var prepareTimer: Timer?
    
    init(dataManager: CoreDataManager, type: WorkoutType?, healthKitManager: HealthKitManager, router: WatchNavigationRouter) {
        self.dataManager = dataManager
        self.workoutType = type
        self.healthKitManager = healthKitManager
        
        // isPairedPublisher emit true -> measurementPublisher se luon nhan dc gia tri moi
        router.isPairedPublisher
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] value in
                guard let self else { return }
                self.isPaired = value
            })
            .filter { $0 }
            .flatMap { _ in
                router.measurementPublisher
            }
            .sink { [weak self] measurement in
                guard let self  else { return }
                // Lưu lại hoặc xử lý measurement
                self.receiveNewMeasurement(measurement)
            }
            .store(in: &cancellables)
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
                        let accel = self.motionManager.currentAccelerationMagnitude()
                        self.motionManager.getSteps(startDate: startDate, endDate: startDate + elapsedTime)
                        if isPaired {
                            self.predictor.predict(accel: accel)
                            self.updateUIFromPredictor()
                        }
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
        
        // check to start timer session
        $isStartingWorkout
            .sink { [weak self] isStartingWorkout in
                guard let self = self else { return }
                if isStartingWorkout {
                    self.startDate = Date()
                    self.workoutStarted = true
                    sessionTimer.start()
                    if !isPaired {
                        self.locationManager.endLocation = nil
                    }
                }
            }
            .store(in: &cancellables)
        
        heartRateMonitor.$currentHeartRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentHeartRate in
                guard let self else { return }
                self.currentHeartRate = HeartRate(id: self.workoutId,
                                                  workoutType: self.workoutType,
                                                  date: self.startDate, value: currentHeartRate)
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .handleEvents(receiveOutput: { print("⏱ Timer emitted: \($0)") })
            .combineLatest(heartRateMonitor.$currentHeartRate
                .handleEvents(receiveOutput: { print("❤️ HeartRate changed: \($0)") }))
            .sink { [weak self] (_, currentHeartRate) in
                guard let self else { return }
                print("🚀 Sending heart rate: \(currentHeartRate)")
                self.watchsessionManager.sendHeartHeartRate(currentHeartRate)
            }
            .store(in: &cancellables)
        
    }
    
    func startWorkout() {
        isStartingWorkout = true
        if isPaired {
            guard let workoutType = workoutType else { return }
            predictor.setWorkoutType(type: workoutType)
        }
    }
    
    func pauseWorkout() {
        watchsessionManager.pauseWorkout()
        sessionTimer.pause()
        isPaused = true
        if !isPaired {
            locationManager.stopLocationServices()
        }
        heartRateMonitor.pauseWorkoutSession()
    }
    
    func resumeWorkout() {
        watchsessionManager.resumeWorkout()
        sessionTimer.resume()
        isPaused = false
        if !isPaired {
            locationManager.startLocationServices()
        }
        heartRateMonitor.resumeWorkoutSession()
    }
    
    func endWorkout() {
        watchsessionManager.endWorkout()
        totalElapsedTime = elapsedTime
        if !isPaired {
            locationManager.stopLocationServices()
        }
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
                if !self.isPaired {
                    self.locationManager.startLocationServices()
                }
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
