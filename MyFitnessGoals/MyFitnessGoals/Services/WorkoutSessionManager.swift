//
//  WorkoutSessionManager.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 13/5/25.
//

import Foundation
import WatchConnectivity
import Combine
import CoreMotion

class WorkoutSessionManager: NSObject, ObservableObject {
    static let shared = WorkoutSessionManager()
    private let session: WCSession
    var router: MobileNavigationRouter?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func isWatchAvailability() -> Bool {
        let session = WCSession.default
        return session.isPaired && session.isWatchAppInstalled
    }
    
    func startWorkout(type: WorkoutType, startDate: Date) {
        let message: [String: Any] = [
            "command": WorkoutCommand.startWorkout.rawValue,
            "type": type.rawValue,
            "startDate": startDate as Any
        ]
        
        sendMessage(message)
    }
    
    func pauseWorkout() {
        let message: [String: Any] = ["command": WorkoutCommand.pauseWorkout.rawValue]
        sendMessage(message)
    }
    
    func resumeWorkout() {
        let message: [String: Any] = ["command": WorkoutCommand.resumeWorkout.rawValue]
        sendMessage(message)
    }
    
    func endWorkout() {
        let message: [String: Any] = ["command": WorkoutCommand.endWorkout.rawValue]
        sendMessage(message)
    }
    
    func updateMetrics(distance: Double, speed: Double, steps: Int, calories: Int) {
        let message: [String: Any] = [
            "command": WorkoutCommand.metrics.rawValue,
            "distance": distance,
            "speed": speed,
            "steps": steps,
            "calories": calories,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        sendMessage(message)
    }
    
    private func sendMessage(_ message: [String: Any]) {
        guard session.activationState == .activated else { return }
        
#if os(iOS)
        guard session.isWatchAppInstalled else { return }
#else
        guard session.isCompanionAppInstalled else { return }
#endif
        
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        } else {
            do {
                try session.updateApplicationContext(message)
            } catch {
                #if DEBUG
                print("Error updating application context: \(error)")
                #endif
            }
        }
    }
    
    func configure(router: MobileNavigationRouter) {
        self.router = router
    }
}

extension WorkoutSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            #if DEBUG
            print("Session activation failed with error: \(error.localizedDescription)")
            #endif
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleMessage(message, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleMessage(applicationContext)
    }
    
    private func handleMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil) {
        #if DEBUG
        print("Received message: \(message)")
        #endif
        
        guard let router = router else { return }
        guard let command = message["command"] as? String else { return }
        
        DispatchQueue.main.async {
            switch command {
            case WorkoutCommand.startWorkout.rawValue:
                self.handleStartWorkout(message: message, router: router)
            case WorkoutCommand.pauseWorkout.rawValue:
                router.shouldPauseWorkout = true
            case WorkoutCommand.resumeWorkout.rawValue:
                router.shouldResumeWorkout = true
            case WorkoutCommand.endWorkout.rawValue:
                router.shouldEndWorkout = true
            case WorkoutCommand.heartRate.rawValue:
                self.handleHeartRate(message: message, router: router)
            case WorkoutCommand.checkPermissions.rawValue:
                self.handleCheckPermissions(replyHandler: replyHandler)
            default:
                break
            }
        }
    }
    
    private func handleStartWorkout(message: [String: Any], router: MobileNavigationRouter) {
        if let typeRaw = message["type"] as? Int16,
           let type = WorkoutType(rawValue: typeRaw) {
            var delay: TimeInterval = 0
            
            if let startDateTimestamp = message["startDate"] as? TimeInterval {
                let startDate = Date(timeIntervalSince1970: startDateTimestamp)
                router.setStartDate(date: startDate)
                let receiveDate = Date()
                delay = receiveDate.timeIntervalSince(startDate)
            }
            router.setDelayTime(time: delay)
            router.startWorkoutThroughWatchCall()
            router.openRecordWorkout(type: type)
        }
    }
    
    private func handleHeartRate(message: [String: Any], router: MobileNavigationRouter) {
        if let heartRateValue = message["value"] as? Double {
            router.setHeartRate(heartRate: heartRateValue)
        }
    }
    
    private func handleCheckPermissions(replyHandler: (([String: Any]) -> Void)?) {
        let locationManager = LocationManager()
        let locationGranted = locationManager.isLocationGranted()
        
        let motionManager = MotionManager()
        let motionGranted = motionManager.isMotionGranted()
        
        replyHandler?([
            WorkoutCommand.locationGranted.rawValue: locationGranted,
            WorkoutCommand.motionGranted.rawValue: motionGranted
        ])
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif
}
