//
//  NavigationRouter.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 25/5/25.
//

import Foundation
import Combine
import SwiftUI

class MobileNavigationRouter: ObservableObject {
    static let shared = MobileNavigationRouter()
    
    @Published var shouldStartWorkout = false
    @Published var currentWorkoutType: WorkoutType? = nil
    @Published var shouldStartImmediately: Bool = false
    @Published var shouldPauseWorkout: Bool = false
    @Published var shouldResumeWorkout: Bool = false
    @Published var shouldEndWorkout: Bool = false
    @Published var delayTime: TimeInterval = 0
    @Published var startDate: Date?
    @Published var heartRate: Double?
    
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
        heartRate = nil
        shouldStartWorkout = false
        shouldEndWorkout = false
    }
    
    func endWorkoutThroughWatchCall() {
        currentWorkoutType = nil
        shouldStartWorkout = false
        shouldEndWorkout = true
        currentWorkoutType = nil
        shouldStartImmediately = false
        shouldPauseWorkout = false
        shouldResumeWorkout = false
        delayTime = 0
        startDate = nil
        heartRate = nil
    }
    
    func setHeartRate(heartRate: Double) {
        self.heartRate = heartRate
    }
    
    func startWorkoutFlow() {
        shouldStartWorkout = true
    }
}

