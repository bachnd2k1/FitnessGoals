//
//  MotionManager.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation
import CoreMotion
import UIKit
import Combine

@MainActor
class MotionManager: ObservableObject {
    private let pedometer: CMPedometer
    var isPedometerAvailable: Bool {
        CMPedometer.isStepCountingAvailable()
    }
    @Published var steps: Int?
    @Published var error: String = ""
    @Published var isAuthorizeMotion: Bool?
    
    let permissionResult = PassthroughSubject<Bool, Never>()
    
    init() {
        self.pedometer = CMPedometer()
        checkAuthorizationStatusOnLaunch()
    }
    
    func checkAuthorizationStatusOnLaunch() {
        let status = checkAuthorizationStatus()
        updateAuthorizationState(status: status)
    }
    
    func checkAuthorizationStatus() -> CMAuthorizationStatus {
        return CMPedometer.authorizationStatus()
    }
    
    func requestMotionPermission() {
        let status = checkAuthorizationStatus()
        print("Status requestMotionPermission\(status)")
        switch status {
        case .notDetermined:
            let now = Date()
            let fiveMinutesAgo = Calendar.current.date(byAdding: .minute, value: -5, to: now) ?? now
            pedometer.queryPedometerData(from: fiveMinutesAgo, to: now) { _, error in
                DispatchQueue.main.async {
                    let newStatus = CMPedometer.authorizationStatus()
                    print("Updated Status: \(newStatus)")
                    self.permissionResult.send(true)
                    switch newStatus {
                    case .authorized:
                        self.isAuthorizeMotion = true
                        print("User Allowed Motion Permission ✅")
                    case .denied:
                        self.isAuthorizeMotion = false
                        print("User Denied Motion Permission ❌")
//                        self.openAppSettings()
                    default:
                        break
                    }
                }
            }
        case .denied:
            DispatchQueue.main.async {
                //                self.updateAuthorizationState(status: .denied)
                self.isAuthorizeMotion = false
            }
#if os(iOS)
            openAppSettings()
#endif
        case .authorized:
            DispatchQueue.main.async {
                //                self.updateAuthorizationState(status: .authorized)
                self.isAuthorizeMotion = true
            }
        default:
            break
        }
        
        print("Status requestMotionPermission after \(status)")
    }
    
    func updateAuthorizationState(status: CMAuthorizationStatus) {
        switch status {
        case .notDetermined:
            isAuthorizeMotion = nil
        case .denied:
            isAuthorizeMotion = false
        case .authorized:
            isAuthorizeMotion = true
        default:
            break
        }
    }
    
    #if os(iOS)
    func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    #endif
    
    func getSteps(startDate: Date, endDate: Date)  {
        if isPedometerAvailable {
            self.pedometer.queryPedometerData(from: startDate, to: endDate) { [weak self] data, error in
                if let data = data {
                    DispatchQueue.main.schedule {
                        self?.steps = data.numberOfSteps.intValue
                    }
                } else if let error = error {
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
