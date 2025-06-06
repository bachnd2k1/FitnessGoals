//
//  HeartRateMonitor.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 6/5/25.
//

import Foundation
import HealthKit
import Combine

class HeartRateMonitor: NSObject, ObservableObject {
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    
    @Published var currentHeartRate: Double = 0.0  // Bind this to your UI if needed
    
    func startWorkoutSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session?.delegate = self  // ✅ Add delegate
            
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            builder?.delegate = self

            guard let session = session, let builder = builder else {
                print("Failed to create session or builder")
                return
            }
            
            print("Session state before start: \(session.state.rawValue)")

            if session.state == .notStarted {
                session.startActivity(with: Date())
                builder.beginCollection(withStart: Date()) { (success, error) in
                    if success {
                        print("✅ Successfully began collection")
                    } else {
                        print("❌ Failed to begin collection: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("⚠️ Session is in unexpected state: \(session.state.rawValue)")
            }

        } catch {
            print("❌ Error starting session: \(error.localizedDescription)")
        }
    }
    
    func stopWorkoutSession() {
        guard let session = session, let builder = builder else { return }
        
        session.end()
        builder.endCollection(withEnd: Date()) { (success, error) in
            if success {
                builder.finishWorkout { workout, error in
                    if let error = error {
                        print("❌ Failed to finish workout: \(error.localizedDescription)")
                    } else {
                        print("✅ Workout finished: \(String(describing: workout))")
                    }
                }
            } else {
                print("❌ Failed to end collection: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func resumeWorkoutSession() {
        guard let session = session else {
            print("⚠️ No active session to resume")
            return
        }
        
        if session.state == .paused {
            session.resume()
            print("▶️ Workout resumed")
        } else {
            print("⚠️ Cannot resume because session is in state: \(session.state.rawValue)")
        }
    }
    
    func pauseWorkoutSession() {
        guard let session = session else {
            print("⚠️ No active session to pause")
            return
        }
        
        if session.state == .running {
            session.pause()
            print("⏸️ Workout paused")
        } else {
            print("⚠️ Cannot pause because session is in state: \(session.state.rawValue)")
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension HeartRateMonitor: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              collectedTypes.contains(heartRateType) else {
            return
        }

        if let statistics = workoutBuilder.statistics(for: heartRateType),
           let value = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) {
            let roundedValue = round(value * 10) / 10
            DispatchQueue.main.async {
                self.currentHeartRate = roundedValue
                print("❤️ Current Heart Rate: \(value) BPM")
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // You can handle workout events here if needed
        print("🏷️ WorkoutBuilder did collect event")
    }
}

// MARK: - HKWorkoutSessionDelegate

extension HeartRateMonitor: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("🔄 WorkoutSession state changed from \(fromState.rawValue) to \(toState.rawValue)")
        
        switch toState {
        case .ended:
            // Optional: handle session ended
            print("🏁 Session ended")
        default:
            break
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("❗️ WorkoutSession failed: \(error.localizedDescription)")
        // Optional: reset session & builder here if needed
    }
}
