import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func checkPermissionsStatusFromPhone() {
        let message: [String: Any] = ["command": "checkPermissions"]
        sendMessageToPhone(message, errorHandler:  { response in
            print("Permission status from phone: \(response)")
            // You can handle this response to show status in Watch UI
        })
    }
    
    func sendHeartHeartRate(_ heartRate: Double) {
        let message: [String: Any] = ["command": WorkoutCommand.heartRate.rawValue, "value": heartRate]
        sendMessageToPhone(message)
    }

    
    func startWorkout(type: WorkoutType) {
        let triggerTime = Date()
        
        let message: [String: Any] = [
            "command": WorkoutCommand.startWorkout.rawValue,
            "type": type.rawValue,
            "startDate": triggerTime.timeIntervalSince1970
        ]
        
        sendMessageToPhone(message)
    }
    
    func pauseWorkout() {
        let message: [String: Any] = ["command": WorkoutCommand.pauseWorkout.rawValue]
        sendMessageToPhone(message)
    }
    
    func resumeWorkout() {
        let message: [String: Any] = ["command": WorkoutCommand.resumeWorkout.rawValue]
        sendMessageToPhone(message)
    }
    
    func endWorkout() {
        let message: [String: Any] = ["command": WorkoutCommand.endWorkout.rawValue]
        sendMessageToPhone(message)
    }

    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch session activation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("Watch session activated with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // Handle incoming messages from iPhone
            print("Watch received message from iPhone: \(message)")
        }
    }
    
    func sendMessageToPhone(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        guard WCSession.default.activationState == .activated else {
            print("Cannot send message: WatchConnectivity session has not been activated")
            errorHandler?(NSError(domain: "WatchSessionManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "WatchConnectivity session has not been activated"]))
            return
        }
        
        guard WCSession.default.isReachable else {
            print("iPhone không reachable – chưa chạy hoặc chưa kết nối WatchConnectivity")
            return
        }
        
        WCSession.default.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
} 
