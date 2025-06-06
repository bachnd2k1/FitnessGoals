//
//  WatchSessionManager.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 13/5/25.
//

//import Foundation
//import WatchConnectivity
//import Combine
//
//class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
//    static let shared = WatchSessionManager()
//    private let session: WCSession
//
//    private override init() {
//        self.session = WCSession.default
//        super.init()
//        activateSession()
//    }
//
//    func activateSession() {
//        if WCSession.isSupported() {
////            let session = WCSession.default
//            print("Is Paired: \(session.isPaired)")
//            print("Is Reachable: \(session.isReachable)")
//            print("Is Complication Enabled: \(session.isComplicationEnabled)")
//            print("Is iOS App Installed: \(session.isWatchAppInstalled)")
//            session.delegate = self
//            session.activate()
//        } else {
//            print("Unpair with watch)")
//        }
//    }
//
//    // MARK: - WCSessionDelegate
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        if let error = error {
//            print("iPhone session activation failed with error: \(error.localizedDescription)")
//            return
//        }
//
//
//        print("iPhone session activated with state: \(activationState.rawValue)")
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        DispatchQueue.main.async {
//            if message["action"] as? String == "startWorkout" {
//                print("Watch triggered the button!")
//                NotificationCenter.default.post(name: .watchDidTriggerAction, object: nil)
//            }
//        }
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        DispatchQueue.main.async {
//            if message["action"] as? String == "startWorkout" {
//                print("✅ Watch triggered the button!")
//                NotificationCenter.default.post(name: .watchDidTriggerAction, object: nil)
//            }
//
//            // Phản hồi lại để tránh lỗi deliveryFailed
//            replyHandler(["status": "received"])
//        }
//    }
//
//    func sendMessageToWatch(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
//        guard WCSession.default.activationState == .activated else {
//            print("Cannot send message: WatchConnectivity session has not been activated")
//            errorHandler?(NSError(domain: "WatchSessionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "WatchConnectivity session has not been activated"]))
//            return
//        }
//
//        guard WCSession.default.isWatchAppInstalled else {
//            print("Cannot send message: Watch app is not installed")
//            errorHandler?(NSError(domain: "WatchSessionManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Watch app is not installed"]))
//            return
//        }
//
//        WCSession.default.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
//    }
//
//    #if os(iOS)
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("iPhone session became inactive")
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("iPhone session deactivated - reactivating...")
//        WCSession.default.activate()
//    }
//    #endif
//}

import Foundation
import WatchConnectivity
import Combine
import CoreMotion

class WorkoutSessionManager: NSObject, ObservableObject {
    static let shared = WorkoutSessionManager()
    private let session: WCSession
    var router: NavigationRouter?
    
    @Published var isWorkoutActive = false
    @Published var workoutType: WorkoutType?
    @Published var startDate: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var speed: Double = 0
    @Published var heartRate: Double = 0
    @Published var steps: Int = 0
    @Published var calories: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func startWorkout(type: WorkoutType) {
        workoutType = type
        startDate = Date()
        isWorkoutActive = true
        
        let message: [String: Any] = [
            "command": "startWorkout",
            "type": type.rawValue,
            "startDate": startDate as Any
        ]
        
        sendMessage(message)
        NotificationCenter.default.post(name: .workoutDidStart, object: nil, userInfo: ["type": type])
    }
    
    func pauseWorkout() {
        isWorkoutActive = false
        let message: [String: Any] = ["command": "pauseWorkout"]
        sendMessage(message)
        NotificationCenter.default.post(name: .workoutDidPause, object: nil)
    }
    
    func resumeWorkout() {
        isWorkoutActive = true
        let message: [String: Any] = ["command": "resumeWorkout"]
        sendMessage(message)
        NotificationCenter.default.post(name: .workoutDidResume, object: nil)
    }
    
    func endWorkout() {
        isWorkoutActive = false
        let message: [String: Any] = ["command": "endWorkout"]
        sendMessage(message)
        NotificationCenter.default.post(name: .workoutDidEnd, object: nil)
    }
    
    func updateMetrics(distance: Double, speed: Double, heartRate: Double, steps: Int, calories: Int) {
        self.distance = distance
        self.speed = speed
        self.heartRate = heartRate
        self.steps = steps
        self.calories = calories
        
        let message: [String: Any] = [
            "command": "updateMetrics",
            "distance": distance,
            "speed": speed,
            "heartRate": heartRate,
            "steps": steps,
            "calories": calories
        ]
        
        sendMessage(message)
        NotificationCenter.default.post(
            name: .workoutDidUpdateMetrics,
            object: nil,
            userInfo: [
                "distance": distance,
                "speed": speed,
                "heartRate": heartRate,
                "steps": steps,
                "calories": calories
            ]
        )
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
                print("Error updating application context: \(error)")
            }
        }
    }
    
    func configure(router: NavigationRouter) {
        self.router = router
    }
}

extension WorkoutSessionManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
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
        print("===>>> message", message)
        guard let router = router else { return }
        guard let command = message["command"] as? String else { return }
        DispatchQueue.main.async {
            switch command {
            case WorkoutCommand.startWorkout.rawValue:
                if let typeRaw = message["type"] as? Int16,
                   let type = WorkoutType(rawValue: typeRaw) {
                    DispatchQueue.main.async {
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
            case WorkoutCommand.pauseWorkout.rawValue:
                router.shouldPauseWorkout = true
            case WorkoutCommand.resumeWorkout.rawValue:
                router.shouldResumeWorkout = true
            case  WorkoutCommand.endWorkout.rawValue:
                router.shouldEndWorkout = true
            case WorkoutCommand.heartRate.rawValue:
                if let heartRateValue = message["value"] as? Double {
                    router.setHeartRate(heartRate: heartRateValue)
                }
//            case "updateMetrics":
//                if let distance = message["distance"] as? Double {
//                    self.distance = distance
//                }
//                if let speed = message["speed"] as? Double {
//                    self.speed = speed
//                }
//                if let heartRate = message["heartRate"] as? Double {
//                    self.heartRate = heartRate
//                }
//                if let steps = message["steps"] as? Int {
//                    self.steps = steps
//                }
//                if let calories = message["calories"] as? Int {
//                    self.calories = calories
//                }
//            case "checkPermissions":
//                let motionStatus = CMMotionActivityManager.authorizationStatus()
//                let locationStatus = CLLocationManager.authorizationStatus()
//                
//                let permissionStatus: [String: Any] = [
//                    "motion": motionStatus.rawValue, // Int
//                    "location": locationStatus.rawValue // Int
//                ]
//                replyHandler?(permissionStatus)
            default:
                break
            }
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
#endif
}
