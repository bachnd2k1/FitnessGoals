//
//  NavigationRouter.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 25/5/25.
//

import Foundation
import Combine
import SwiftUI

class NavigationRouter: ObservableObject {
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
    
    func endWorkoutThroughWatchCall() {
        shouldEndWorkout = true
        currentWorkoutType = nil
        shouldStartImmediately = false
        delayTime = 0
        startDate = nil
        heartRate = nil
    }
    
    func setHeartRate(heartRate: Double) {
        self.heartRate = heartRate
    }
}

