import Foundation
import Combine
import WatchConnectivity

class WatchTimerManager: NSObject, ObservableObject {
    static let shared = WatchTimerManager()
    private let session: WCSession
    
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    private var timer: Timer?
    private var startDate: Date?
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func startTimer() {
        startDate = Date()
        isRunning = true
        
        // Send start command to other device
        let message: [String: Any] = [
            "command": "startTimer",
            "startDate": startDate as Any
        ]
        sendMessage(message)
        
        // Start local timer
        startLocalTimer()
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Send stop command to other device
        let message: [String: Any] = ["command": "stopTimer"]
        sendMessage(message)
    }
    
    private func startLocalTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startDate = self.startDate else { return }
            self.elapsedTime = Date().timeIntervalSince(startDate)
        }
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

extension WatchTimerManager: WCSessionDelegate {
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
            case "startTimer":
                if let startDate = message["startDate"] as? Date {
                    self.startDate = startDate
                    self.isRunning = true
                    self.startLocalTimer()
                }
            case "stopTimer":
                self.isRunning = false
                self.timer?.invalidate()
                self.timer = nil
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