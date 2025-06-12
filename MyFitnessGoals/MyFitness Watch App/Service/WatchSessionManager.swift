import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    var router: WatchNavigationRouter?
    
    
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
    
    func configure(router: WatchNavigationRouter) {
        self.router = router
    }
    
    private func checkPermissionsStatusFromPhone() {
        let message: [String: Any] = ["command": WorkoutCommand.checkPermissions.rawValue]
        sendMessageToPhone(
        message,
        replyHandler: { response in
            if let isLocationGranted = response[WorkoutCommand.locationGranted.rawValue] as? Bool,
               let isMotionGranted = response[WorkoutCommand.motionGranted.rawValue] as? Bool {
                print("Location: \(isLocationGranted), Motion: \(isMotionGranted)")
                self.router?.updateLocationPermission(isLocationPermission: isLocationGranted)
                self.router?.updateMotionPermission(isMotionPermission: isMotionGranted)
            }
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
        
//        WCSession.default.transferUserInfo(["startWorkout": true])
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
            case WorkoutCommand.metrics.rawValue:
                guard let distance = message["distance"] as? Double,
                      let speed = message["speed"] as? Double,
                      let calories = message["calories"] as? Int,
                      let steps = message["steps"] as? Int,
                      let timeStamp = message["timestamp"] as? TimeInterval
                else {
                    return
                }
                
                let measurement = WorkoutMeasurement(
                    timestamp: timeStamp,
                    distance: distance,
                    speed: speed,
                    calories: calories,
                    steps: steps
                )
                
                DispatchQueue.main.async {
                    router.updateMetrics(latestMeasurement: measurement)
                }
            default:
                break
            }
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
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            let isPaired = session.isReachable
            print("??? sessionReachabilityDidChange is paired: \(isPaired)")
            self.router?.updatePairingState(isPaired: isPaired)
            if isPaired {
                self.checkPermissionsStatusFromPhone()
            }
        }
    }
}
