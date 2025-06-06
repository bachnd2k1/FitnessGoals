import Foundation
import WatchConnectivity
import Combine

class WorkoutSessionManager: NSObject, ObservableObject {
    static let shared = WorkoutSessionManager()
    private let session: WCSession
    
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
                }
            case "pauseWorkout":
                self.isWorkoutActive = false
            case "resumeWorkout":
                self.isWorkoutActive = true
            case "endWorkout":
                self.isWorkoutActive = false
            case "updateMetrics":
                if let distance = message["distance"] as? Double {
                    self.distance = distance
                }
                if let speed = message["speed"] as? Double {
                    self.speed = speed
                }
                if let heartRate = message["heartRate"] as? Double {
                    self.heartRate = heartRate
                }
                if let steps = message["steps"] as? Int {
                    self.steps = steps
                }
                if let calories = message["calories"] as? Int {
                    self.calories = calories
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