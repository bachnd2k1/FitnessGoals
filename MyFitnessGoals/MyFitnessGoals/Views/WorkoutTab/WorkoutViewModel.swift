//
//  WorkoutViewModel.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class WorkoutViewModel: ObservableObject {
    private let locationManager = LocationManager()
    private let timer = TimerManager()
    private let motionManager = MotionManager()
    private let dataManager: CoreDataManager
    private let healthKitManager: HealthKitManager
    @Published var state: TimerMode?
    @Published var elapsedTime: TimeInterval = 0
    @Published var timerIsNil: Bool = true
    @Published var workoutStarted: Bool = false
    @Published var startDate: Date?
    @Published var distance: Distance?
    @Published var speed: Speed?
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
    @Published var hasLocationPermission: Bool = false
    @Published var hasMotionPermission: Bool = false
    @Published var didCancelWorkout: Bool = false
    
    @Published var motionAccessIsDenied: Bool = false
    @Published var motionAccessThrowsError: Bool = false
    @Published var motionAccessNotDetermine: Bool = false
    
    @Published var isPreparing = false
    @Published var countdown = 5
    @Published var showCountdownView = false
    @Published var isStartingWorkout = false
    
    let delayCounterTimer = 3.0


    private var updateMetricsTimer: DispatchSourceTimer?
    private var prepareTimer: Timer?
    var timerIsPaused: Bool { state == .paused }
    var workoutType: WorkoutType?
    private var workoutId: UUID = UUID()
    
    
    private var cancellables: Set<AnyCancellable> = []
    private var isPaused = false
    
    #if os(iOS)
    private var manager = LiveActivityManager.shared
    private var timerLiveActivity: Timer?
    #endif
    
    deinit {
        prepareTimer?.invalidate()
        prepareTimer = nil
        
        updateMetricsTimer?.cancel()
        updateMetricsTimer = nil
    }
    
    init(dataManager: CoreDataManager, type: WorkoutType?, healthKitManager: HealthKitManager, workoutSessionManager: WorkoutSessionManager) {
        self.dataManager = dataManager
        self.workoutType = type
        self.healthKitManager = healthKitManager
        locationManager.$locations.assign(to: &$route)
        locationManager.$endLocation.assign(to: &$endLocation)
        locationManager.$locationAccessIsDenied.assign(to: &$locationAccessIsDenied)
        locationManager.$locationAccessThrowsError.assign(to: &$locationAccessThrowsError)
        locationManager.$locationAccessError.assign(to: &$locationAccessError)
        timer.$isNil.assign(to: &$timerIsNil)
        
        timer.$state
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancellables)
        
        timer.$elapsedTime.assign(to: &$elapsedTime)
        locationManager.distancePublisher
            .sink { [weak self] distanceValue in
                if let self {
                    distance = Distance(
                        id: workoutId, workoutType: workoutType,
                        date: startDate, measure: distanceValue)
                }
            }
            .store(in: &cancellables)
        locationManager.speedPublisher
            .sink { [weak self] speedValue in
                if let self {
                    speed = Speed(
                        id: workoutId, workoutType: workoutType,
                        date: startDate, measure: speedValue)
                }
            }
            .store(in: &cancellables)
        $elapsedTime
            .sink { [weak self] elapsedTime in
                if let self, let startDate, elapsedTime > 0 {
                    if let workoutType, workoutType != .cycling {
                        motionManager.getSteps(startDate: startDate, endDate: startDate + elapsedTime)
                    }
                }
            }
            .store(in: &cancellables)
        
        motionManager.$steps
            .sink { [weak self] stepValue in
                if let self {
                    steps = Step(
                        id: workoutId, workoutType: workoutType,
                        date: startDate, count: stepValue ?? 0)
                }
            }
            .store(in: &cancellables)
                
        motionManager.$motionAccessIsDenied
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessIsDenied)

        motionManager.$motionAccessNotDetermine
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessNotDetermine)

        motionManager.$motionAccessThrowsError
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessThrowsError)

        
        $isStartingWorkout
            .sink { [weak self] isStartingWorkout in
                guard let self = self else { return }
                if isStartingWorkout {
                    startDate = startDate ?? Date()
                    workoutStarted = true
                    timer.start()
                    locationManager.startLocationServices()
                    locationManager.endLocation = nil
                    startTimer()
                    updateMetricsTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
                    updateMetricsTimer?.schedule(deadline: .now(), repeating: 5.0)
                    updateMetricsTimer?.setEventHandler { [weak self] in
                        guard let self else { return }
                        let distance = self.distance?.value ?? 1
                        let step = self.steps?.count ?? 1
                        let calories = self.calories?.count ?? 1
                        let speed = self.speed?.value ?? 1
                        workoutSessionManager.updateMetrics(distance: distance, speed: speed / 3.6, steps: step, calories: calories)
                    }
                    updateMetricsTimer?.resume()
                }
            }
            .store(in: &cancellables)
        
        locationManager.$locationAccessIsDenied
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationAccessIsDenied)
        
        locationManager.$locationAccessNotDetermine
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationAccessNotDetermine)
        
        locationManager.$totalDistance
            .sink { [weak self] totalDistance in
                guard let self else { return }
                switch workoutType {
                case .running:
                    calories = Calorie(id: workoutId, workoutType: workoutType, date: startDate,
                                       count: Int(totalDistance / 1000 * 70))
                case .walking:
                    calories = Calorie(id: workoutId, workoutType: workoutType, date: startDate,
                                       count: Int(totalDistance / 1000 * 55))
                case .cycling:
                    calories = Calorie(id: workoutId, workoutType: workoutType, date: startDate,
                                       count: Int(totalDistance / 1000 * 25))
                case nil:
                    break
                }
            }
            .store(in: &cancellables)
        
        motionManager.$motionAccessNotDetermine
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessNotDetermine)
        
        locationManager.$locationAccessIsDenied
            .combineLatest(locationManager.$locationAccessThrowsError,
                               locationManager.$locationAccessNotDetermine)
            .map { !$0 && !$1 && !$2 }
            .assign(to: &$hasLocationPermission)

        motionManager.$motionAccessIsDenied
            .combineLatest(motionManager.$motionAccessThrowsError,
                               motionManager.$motionAccessNotDetermine)
            .map { !$0 && !$1 && !$2 }
            .assign(to: &$hasMotionPermission)
        
        #if os(iOS)
        manager.onPauseAction = {
            DispatchQueue.main.async {
                self.pauseWorkout()
            }
        }
        
        manager.onContinueAction = {
            DispatchQueue.main.async {
                self.resumeWorkout()
            }
        }
        
        manager.onStopAction = {
            DispatchQueue.main.async {
                self.endWorkout()
                self.addWorkout()
            }
        }
        #endif
        
    }
    
    // Trong View hoặc ViewModel
    func permissionState(for permission: PermissionInfo) -> PermissionState {
        switch permission {
        case .location:
            return PermissionState(
                isDenied: locationAccessIsDenied,
                isNotDetermined: locationAccessNotDetermine
            )
        case .motion:
            return PermissionState(
                isDenied: motionAccessIsDenied,
                isNotDetermined: motionAccessNotDetermine
            )
        case .health:
            return PermissionState(
                isDenied: false,
                isNotDetermined: false
            )
        }
    }
    
    func requestPermissonHealthKit() {
        healthKitManager.requestAuthorization()
    }
    
    private func startTimer() {
        #if os(iOS)
        timerLiveActivity = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.manager.updateActivity(
                    time: self.formatTimeIntervalToString(self.elapsedTime),
                    step: Int(self.steps?.value ?? 0.0),
                    distance: self.distanceFormatter(for: self.distance?.measure.value ?? 0) ?? "0",
                    speed: self.speedFormatter(for: self.speed?.measure.value ?? 0.0) ?? "0",
                    type: self.workoutType?.name ?? WorkoutType.running.name,
                    icon: self.workoutType?.icon ?? WorkoutType.running.icon,
                    isPaused: !self.isPaused
                )
            }
        }
        #endif
    }
    
    private func stopLiveActivityTimer() {
        #if os(iOS)
        timerLiveActivity?.invalidate()
        timerLiveActivity = nil
        #endif
    }
    
    private func formatTimeIntervalToString(_ elapsedTime: TimeInterval) -> String {
        let duration = Duration(
            secondsComponent: Int64(elapsedTime),
            attosecondsComponent: 0
        )
        
        if elapsedTime >= 3600 {
            return duration.formatted(.time(pattern: .hourMinuteSecond(padHourToLength: 2)))
        } else {
            return duration.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
        }
    }
    
    
    private func distanceFormatter(for value: Double?) -> String? {
        // conversion meters -> kilometers
        guard let valueInMeters = value else { return nil }
        return formatter.string(for: (valueInMeters / 1000))
    }
    
    private func speedFormatter(for value: Double?) -> String? {
        // conversion meters/second -> kilometers/hour
        guard let valueInMetersPerSecond = value else { return nil }
        return formatter.string(for: (valueInMetersPerSecond * 3.6))
    }
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
        
    func startCountdown(delay: TimeInterval = 0.0, startDate: Date? = nil) {
        isPreparing = true
        self.startDate = startDate
        DispatchQueue.main.asyncAfter(deadline: .now() + delayCounterTimer - delay) {
            Task { @MainActor in
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
                            self.beginWorkout()
                        }
                    }
                }
            }
        }
    }

    
    func requestPermisson() {
        #if os(iOS)
        locationManager.requestPermission()
        motionManager.requestMotionPermission()
        #endif
    }
    
    func beginWorkout() {
        isStartingWorkout = true
    }
    
    func pauseWorkout() {
        timer.pause()
        isPaused = true
        locationManager.stopLocationServices()
        
        #if os(iOS)
        manager.updateLiveActivity(isPaused: isPaused)
        #endif
    }
    
    func resumeWorkout() {
        timer.resume()
        isPaused = false
        locationManager.startLocationServices()
        
        #if os(iOS)
        manager.updateLiveActivity(isPaused: isPaused)
        #endif
    }
    
    func endWorkout() {
        totalElapsedTime = elapsedTime
        locationManager.stopLocationServices()
        getMetrics()
        timer.stop()
        didCancelWorkout = true
        isStartingWorkout = false
        
        #if os(iOS)
        manager.endActivity()
        stopLiveActivityTimer()
        #endif
    }
    
    func cancelWorkout() {
        locationManager.stopLocationServices()
        timer.stop()
        isStartingWorkout = false
        
        resetState()
        
        #if os(iOS)
        manager.endActivity()
        #endif
    }
    
    func addWorkout() {
        let workout = Workout(
            id: workoutId,
            date: startDate,
            type: workoutType,
            route: route,
            duration: totalElapsedTime,
            distance: distance,
            speed: speed,
            distances: locationManager.distances,
            speeds: locationManager.speeds,
            altitudes: locationManager.altitudes,
            steps: steps,
            calories: calories)
        dataManager.add(workout)
        dataManager.addMetrics(to: workout)
        resetState()
    }
    
    private func getMetrics() {
        let totalDistance = locationManager.totalDistance
        distance = Distance(id: workoutId, workoutType: workoutType, date: startDate,
                            measure: Measurement.init(value: totalDistance, unit: .meters))
        let averageSpeed = totalDistance / elapsedTime
        speed = Speed(id: workoutId, workoutType: workoutType, date: startDate,
                      measure: Measurement.init(value: averageSpeed, unit: .metersPerSecond))
        
        calculateCalories()
    }
    
    func calculateCalories() {
        let age = UserDefaults.standard.getInt(for: .weight) ?? 30
        let gender = UserDefaults.standard.getString(for: .gender) ?? "Male"
        let weight = UserDefaults.standard.getInt(for: .weight) ?? 70
        let height = UserDefaults.standard.getInt(for: .height) ?? 150
        
        // BMR (Basal Metabolic Rate) là tỷ lệ trao đổi chất cơ bản của cơ thể
        // CT tính calories: Calories = (BMR / 24) × MET × duration (giờ)
        
        // CT BMR theo Mifflin–St Jeor Equation:
        // Nữ giới: BMR = 10 × weight (kg) + 6.25 × height (cm) – 5 × age – 161
        // Nam giới: 10 × weight (kg) + 6.25 × height (cm) – 5 × age + 5
        
        if let distance = distance?.value, let speed = speed?.value, speed != 0, distance != 0 {
            let duration = distance / speed
            var met = 0.0
            switch workoutType {
            case .running:
                met = 9.8
            case .walking:
                met = 3.8
            case .cycling:
                met = 6.8
            case .none:
                break
            }
            
            // Tính BMR
            let bmr: Double
            
            if gender == "Male" {
                bmr = 10.0 * Double(weight) + 6.25 * Double(height) - 5.0 * Double(age) + 5
            } else {
                bmr = 10.0 * Double(weight) + 6.25 * Double(height) - 5.0 * Double(age) - 161
            }
            
            // Calories tiêu hao
            let caloriesBurned = (bmr / 24.0) * met * duration
            calories = Calorie(id: workoutId, workoutType: workoutType, date: startDate,
                                                   count: Int(caloriesBurned))
        }
    }
    
    
    func resetState() {
        // Core workout state
        state = nil
        elapsedTime = 0
        totalElapsedTime = 0
        timerIsNil = true
        workoutStarted = false
        isStartingWorkout = false
        isPreparing = false
        showCountdownView = false
        countdown = 5

        // Workout metadata
        startDate = nil
        workoutId = UUID()

        // Metrics
        distance = nil
        speed = nil
        steps = nil
        calories = nil

        // Route & location
        route.removeAll()
        endLocation = nil
        
        locationManager.reset()
        motionManager.reset()

        // Internal flags
        didCancelWorkout = false
        isPaused = false

        // Timers
        prepareTimer?.invalidate()
        prepareTimer = nil
        updateMetricsTimer?.cancel()
        updateMetricsTimer = nil
    }
}
