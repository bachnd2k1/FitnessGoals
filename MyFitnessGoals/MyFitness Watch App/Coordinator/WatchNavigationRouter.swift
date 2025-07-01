//
//  WatchNavigationRouter.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 9/6/25.
//

import Foundation
import Combine
import SwiftUI

class WatchNavigationRouter: ObservableObject {
    
    // Sử dụng @Published gây re-render UI
    
    let measurementPublisher = PassthroughSubject<WorkoutMeasurement, Never>()
    let isPairedPublisher = CurrentValueSubject<Bool, Never>(false)
    
    @Published var isLocationPermission: Bool = true
    @Published var isMotionPermission: Bool = true
    
    @Published var shouldStartWorkout = false
    @Published var currentWorkoutType: WorkoutType? = nil
    @Published var shouldStartImmediately: Bool = false
    @Published var shouldPauseWorkout: Bool = false
    @Published var shouldResumeWorkout: Bool = false
    @Published var shouldEndWorkout: Bool = false
    @Published var delayTime: TimeInterval = 0
    @Published var startDate: Date?
    
    func updateMetrics(latestMeasurement: WorkoutMeasurement) {
        measurementPublisher.send(latestMeasurement)
    }
    
    func updateLocationPermission(isLocationPermission: Bool) {
        self.isLocationPermission = isLocationPermission
    }
    
    func updateMotionPermission(isMotionPermission: Bool) {
        self.isMotionPermission = isMotionPermission
    }
    
    func updatePairingState(isPaired: Bool) {
        isPairedPublisher.send(isPaired)
    }
    
    func openRecordWorkout(type: WorkoutType) {
        currentWorkoutType = type
    }
    
    func setDelayTime(time: TimeInterval) {
        delayTime = time
    }
    
    func setStartDate(date: Date) {
        startDate = date
    }
    
    func startWorkoutThroughWatchCall() {
        shouldStartImmediately = true
    }
    
    func pauseWorkoutThroughWatchCall() {
        shouldPauseWorkout = true
    }
    
    func resumeWorkoutThroughWatchCall() {
        shouldResumeWorkout = true
    }
        
    func cancelWorkoutThroughWatchCall() {
        currentWorkoutType = nil
        shouldStartImmediately = false
        shouldPauseWorkout = false
        shouldResumeWorkout = false
        delayTime = 0
        startDate = nil
        shouldStartWorkout = false
        shouldEndWorkout = false
    }
    
    func endWorkoutThroughWatchCall() {
        currentWorkoutType = nil
        shouldStartWorkout = false
        currentWorkoutType = nil
        shouldStartImmediately = false
        shouldPauseWorkout = false
        shouldResumeWorkout = false
        delayTime = 0
        startDate = nil
    }
    
    func startWorkoutFlow() {
        shouldStartWorkout = true
    }
}
