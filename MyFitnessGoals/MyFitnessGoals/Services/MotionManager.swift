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

class MotionManager: ObservableObject {
    private let pedometer: CMPedometer
    private let motionManager = CMMotionManager()
    private var currentAccel: CMAcceleration = .init(x: 0, y: 0, z: 0) // ✳️ Lưu giá trị accelerometer
    
    var isPedometerAvailable: Bool {
        CMPedometer.isStepCountingAvailable()
    }
    @Published var steps: Int?
    @Published var error: String = ""
    @Published var isAuthorizeMotion: Bool?
    @Published var motionAccessNotDetermine: Bool = false
    
    let permissionResult = PassthroughSubject<Bool, Never>()
    
    
    init() {
        self.pedometer = CMPedometer()
        checkAuthorizationStatusOnLaunch()
        
        //#if os(watchOS)
        startAccelerometerUpdates()
        //#endif
    }
    
    func isMotionGranted() -> Bool {
        let motionGranted: Bool = {
            let semaphore = DispatchSemaphore(value: 0)
            var granted = false
            
            CMMotionActivityManager().queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
                granted = (error == nil)
                semaphore.signal()
            }
            
            _ = semaphore.wait(timeout: .now() + 2) // wait max 2 seconds
            return granted
        }()
        
        return motionGranted
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
            motionAccessNotDetermine = true
        case .denied:
            isAuthorizeMotion = false
            motionAccessNotDetermine = false
        case .authorized:
            isAuthorizeMotion = true
            motionAccessNotDetermine = false
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
    
    // MARK: - Accelerometer (gia tốc)
    
    private func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("❌ Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 1.0 / 10.0
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            if let error = error {
                print("❌ Accelerometer error: \(error.localizedDescription)")
            }
            
            if let data = data {
                print("📡 Received accel: x=\(data.acceleration.x), y=\(data.acceleration.y), z=\(data.acceleration.z)")
                self?.currentAccel = data.acceleration
            } else {
                print("⚠️ No accelerometer data")
            }
        }
    }
    
    
    /// Tính độ lớn của vector gia tốc (magnitude)
    func currentAccelerationMagnitude() -> Double {
        let x = currentAccel.x
        let y = currentAccel.y
        let z = currentAccel.z
        return sqrt(x * x + y * y + z * z)
    }
    
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
