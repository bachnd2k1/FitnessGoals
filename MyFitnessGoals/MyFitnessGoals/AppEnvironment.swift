//
//  AppEnvironment.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 11/05/2026.
//

import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let dataManager: CoreDataManager
    let healthKitManager: HealthKitManager
    let workoutSessionManager: WorkoutSessionManager
    let locationManager: LocationManager
    let motionManager: MotionManager
    let calendarManager: CalendarManager

    init(
        dataManager: CoreDataManager = .shared,
        healthKitManager: HealthKitManager = .shared,
        workoutSessionManager: WorkoutSessionManager = .shared,
        locationManager: LocationManager = LocationManager(),
        motionManager: MotionManager = MotionManager(),
        calendarManager: CalendarManager = CalendarManager()
    ) {
        self.dataManager = dataManager
        self.healthKitManager = healthKitManager
        self.workoutSessionManager = workoutSessionManager
        self.locationManager = locationManager
        self.motionManager = motionManager
        self.calendarManager = calendarManager
    }
}
