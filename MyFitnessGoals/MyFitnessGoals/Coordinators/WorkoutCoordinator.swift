import Foundation
import Combine
import WatchConnectivity

class WorkoutCoordinator: NSObject {
    static let shared = WorkoutCoordinator()
    
    private let session: WCSession
    private var cancellables = Set<AnyCancellable>()
    
    // Current workout state
    @Published private(set) var isWorkoutActive = false
    @Published private(set) var workoutType: WorkoutType?
    @Published private(set) var startDate: Date?
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var distance: Double = 0
    @Published private(set) var speed: Double = 0
    @Published private(set) var heartRate: Double = 0
    @Published private(set) var steps: Int = 0
    @Published private(set) var calories: Int = 0
    
    // Callbacks
    var onWorkoutStart: ((WorkoutType) -> Void)?
    var onWorkoutPause: (() -> Void)?
    var onWorkoutResume: (() -> Void)?
    var onWorkoutEnd: (() -> Void)?
    var onMetricsUpdate: ((WorkoutMetrics) -> Void)?
    
    private override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkoutStart),
            name: .workoutDidStart,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkoutPause),
            name: .workoutDidPause,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkoutResume),
            name: .workoutDidResume,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkoutEnd),
            name: .workoutDidEnd,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkoutMetricsUpdate),
            name: .workoutDidUpdateMetrics,
            object: nil
        )
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
    
    @objc private func handleWorkoutStart(_ notification: Notification) {
        if let type = notification.userInfo?["type"] as? WorkoutType {
            workoutType = type
            startDate = Date()
            isWorkoutActive = true
            onWorkoutStart?(type)
        }
    }
    
    @objc private func handleWorkoutPause(_ notification: Notification) {
        isWorkoutActive = false
        onWorkoutPause?()
    }
    
    @objc private func handleWorkoutResume(_ notification: Notification) {
        isWorkoutActive = true
        onWorkoutResume?()
    }
    
    @objc private func handleWorkoutEnd(_ notification: Notification) {
        isWorkoutActive = false
        onWorkoutEnd?()
    }
    
    @objc private func handleWorkoutMetricsUpdate(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let metrics = WorkoutMetrics(
                distance: userInfo["distance"] as? Double ?? 0,
                speed: userInfo["speed"] as? Double ?? 0,
                heartRate: userInfo["heartRate"] as? Double ?? 0,
                steps: userInfo["steps"] as? Int ?? 0,
                calories: userInfo["calories"] as? Int ?? 0
            )
            onMetricsUpdate?(metrics)
        }
    }
}

extension WorkoutCoordinator: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Session activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessage(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleMessage(applicationContext)
    }
    
    private func handleMessage(_ message: [String: Any]) {
        guard let command = message["command"] as? String else { return }
        
        DispatchQueue.main.async {
            switch command {
            case "startWorkout":
                if let typeRaw = message["type"] as? Int,
                   let type = WorkoutType(rawValue: typeRaw),
                   let startDate = message["startDate"] as? Date {
                    self.workoutType = type
                    self.startDate = startDate
                    self.isWorkoutActive = true
                    self.onWorkoutStart?(type)
                }
            case "pauseWorkout":
                self.isWorkoutActive = false
                self.onWorkoutPause?()
            case "resumeWorkout":
                self.isWorkoutActive = true
                self.onWorkoutResume?()
            case "endWorkout":
                self.isWorkoutActive = false
                self.onWorkoutEnd?()
            case "updateMetrics":
                if let userInfo = message as? [String: Any] {
                    let metrics = WorkoutMetrics(
                        distance: userInfo["distance"] as? Double ?? 0,
                        speed: userInfo["speed"] as? Double ?? 0,
                        heartRate: userInfo["heartRate"] as? Double ?? 0,
                        steps: userInfo["steps"] as? Int ?? 0,
                        calories: userInfo["calories"] as? Int ?? 0
                    )
                    self.onMetricsUpdate?(metrics)
                }
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

struct WorkoutMetrics {
    let distance: Double
    let speed: Double
    let heartRate: Double
    let steps: Int
    let calories: Int
} 