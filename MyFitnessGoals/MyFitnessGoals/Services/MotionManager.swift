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
    private let pedometer = CMPedometer()
    private let motionManager = CMMotionManager()
    private var currentAccel: CMAcceleration = .init(x: 0, y: 0, z: 0) // ✳️ Lưu giá trị accelerometer
    
    var isPedometerAvailable: Bool {
        CMPedometer.isStepCountingAvailable()
    }
    @Published var steps: Int?
    @Published var error: String = ""
    @Published var motionAccessIsDenied: Bool = false
    @Published var motionAccessThrowsError: Bool = false
    @Published var motionAccessNotDetermine: Bool = false
    
    let permissionResult = PassthroughSubject<Bool, Never>()
    
    
    init() {
        checkAuthorizationStatusOnLaunch()
        
        //#if os(watchOS)
//        startAccelerometerUpdates()
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
            requestPermissionViaQuery()
        case .denied:
#if os(iOS)
            openAppSettings()
#endif
        default:
            break
        }
        checkAuthorizationStatusOnLaunch()
        print("Status requestMotionPermission after \(status)")
    }
    
    private func requestPermissionViaQuery() {
        let now = Date()
        let fiveMinutesAgo = Calendar.current.date(byAdding: .minute, value: -5, to: now) ?? now

        pedometer.queryPedometerData(from: fiveMinutesAgo, to: now) { _, _ in
            DispatchQueue.main.async {
                let newStatus = CMPedometer.authorizationStatus()
                self.updateAuthorizationState(status: newStatus)
                self.permissionResult.send(true)
            }
        }
    }
    
//    func updateAuthorizationState(status: CMAuthorizationStatus) {
//        switch status {
//        case .notDetermined:
//            motionAccessIsDenied = false
//            motionAccessNotDetermine = true
//            motionAccessThrowsError = false
//        case .denied:
//            motionAccessIsDenied = true
//            motionAccessNotDetermine = false
//            motionAccessThrowsError = false
//        case .authorized:
//            motionAccessIsDenied = false
//            motionAccessNotDetermine = false
//            motionAccessThrowsError = false
//        default:
//            motionAccessThrowsError = true
//        }
//    }
    
    private func updateAuthorizationState(status: CMAuthorizationStatus) {
        motionAccessIsDenied = (status == .denied)
        motionAccessNotDetermine = (status == .notDetermined)
        motionAccessThrowsError = !(status == .authorized || status == .denied || status == .notDetermined)
    }
    
    func reset() {
        steps = nil
        error = ""
        motionAccessIsDenied = false
        motionAccessThrowsError = false
        motionAccessNotDetermine = false
        currentAccel = .init(x: 0, y: 0, z: 0)
        
        // Optionally stop accelerometer updates if you were using them
        if motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
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
