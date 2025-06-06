//
//  HealthKitManager.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 18/3/25.
//

import Foundation
import HealthKit
import Combine

#if os(watchOS)
import WatchKit
#endif

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    @Published var isNotDetermined: Bool = false
    @Published var isDenied: Bool = false
    @Published var isAuthorized: Bool = false
    @Published var stepCount = ""
    @Published var distance = ""
    @Published var calories = ""
    
    var distanceSubject = CurrentValueSubject<[String], Never>(Array(repeating: "0", count: 7))
    var stepSubject = CurrentValueSubject<[String], Never>(Array(repeating: "0", count: 7))
    var caloriesSubject = CurrentValueSubject<[String], Never>(Array(repeating: "0", count: 7))
    
    let permissionResult = PassthroughSubject<Bool, Never>()
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
            return
        }
        
        var types: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.workoutType()
        ]
        
        #if os(watchOS)
        types.insert(HKObjectType.quantityType(forIdentifier: .heartRate)!)
        #endif
        
        
        healthStore.requestAuthorization(toShare: types, read: types) { success, error in
            DispatchQueue.main.async {
                self.permissionResult.send(true)
                self.updateAuthorizationStatus()
            }
        }
    }
    
    func updateAuthorizationStatus() {
        let stepStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!)
        let distanceStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
        let caloriesStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!)
        
        self.isAuthorized = (stepStatus == .sharingAuthorized &&
                             distanceStatus == .sharingAuthorized &&
                             caloriesStatus == .sharingAuthorized)
        
        self.isNotDetermined = (stepStatus == .notDetermined ||
                                distanceStatus == .notDetermined ||
                                caloriesStatus == .notDetermined)
        
        self.isDenied = (stepStatus == .sharingDenied ||
                         distanceStatus == .sharingDenied ||
                         caloriesStatus == .sharingDenied)
        
        print("===>>> HealthKit isAuthorized status: \(isAuthorized)")
        print("===>>> HealthKit isNotDetermined status: \(isNotDetermined)")
        print("===>>> HealthKit isDenied status: \(isDenied)")
    }
    
    func checkAuthorizationStatus() {
        let stepStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .stepCount)!)
        let distanceStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!)
        let caloriesStatus = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!)
        
        DispatchQueue.main.async {
            self.isAuthorized = (stepStatus == .sharingAuthorized &&
                                 distanceStatus == .sharingAuthorized &&
                                 caloriesStatus == .sharingAuthorized)
            
            self.isNotDetermined = (stepStatus == .notDetermined &&
                                    distanceStatus == .notDetermined &&
                                    caloriesStatus == .notDetermined)
            
            self.isDenied = (stepStatus == .sharingDenied &&
                             distanceStatus == .sharingDenied &&
                             caloriesStatus == .sharingDenied)
        }
    }
    
    func fetchHealthDataForLast7Days(date: Date) {
        let group = DispatchGroup()
        let calendar = Calendar.current
        
        var distances = Array(repeating: "0", count: 7)
        var steps = Array(repeating: "0", count: 7)
        var calories = Array(repeating: "0", count: 7)
        
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: -i, to: date)!
            let startOfDay = calendar.startOfDay(for: day)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)
            
            // 🚀 Fetch Distance
            group.enter()
            let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                defer { group.leave() }
                
                guard let quantity = result?.sumQuantity() else {
                    print("No data available for date: \(day)")
                    return
                }
                
                let distanceValue = quantity.doubleValue(for: HKUnit.meter())
                distances[i] = self.distanceFormatter(for: distanceValue) ?? "0"
            }
            healthStore.execute(distanceQuery)
            
            
            // 🚀 Fetch Steps
            group.enter()
            let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                defer { group.leave() }
                if let quantity = result?.sumQuantity() {
                    steps[i] = String(Int(quantity.doubleValue(for: HKUnit.count())))
                }
            }
            healthStore.execute(stepQuery)
            
            // 🚀 Fetch Calories
            group.enter()
            let calorieQuery = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                defer { group.leave() }
                if let quantity = result?.sumQuantity() {
                    calories[i] = String(Int(quantity.doubleValue(for: HKUnit.kilocalorie())))
                }
            }
            healthStore.execute(calorieQuery)
            
        }
        
        group.notify(queue: .main) {
            if distances.contains(where: { $0 != "0" }) ||
                steps.contains(where: { $0 != "0" }) ||
                calories.contains(where: { $0 != "0" }) {
                self.distanceSubject.send(distances)
                self.stepSubject.send(steps)
                self.caloriesSubject.send(calories)
            }
        }
    }
    
    func fetchStepCount(date: Date) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                self.stepCount = String(Int(stepCount))
            }
        }
        
        healthStore.execute(query)
    }
    
    //    func fetchDistance(date: Date) {
    //        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    //        let startOfDay = Calendar.current.startOfDay(for: date)
    //
    //        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
    //
    //        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
    //            let distance = result?.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
    //            self.distance = self.distanceFormatter(for: distance) ?? "0"
    //        }
    //        print("Date - \(date) | distance - \(distance)")
    //        healthStore.execute(query)
    //    }
    
    func fetchDistance(date: Date) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let quantity = result?.sumQuantity() else {
                print("No data available for date: \(date)")
                return
            }
            
            let distanceValue = quantity.doubleValue(for: HKUnit.meter())
            
            DispatchQueue.main.async {
                self.distance = self.distanceFormatter(for: distanceValue) ?? "0"
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchActiveCalories(date: Date) {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            DispatchQueue.main.async {
                self.calories = String(Int(calories))
            }
        }
        
        healthStore.execute(query)
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
}
