//
//  WelcomeFlowViewModel.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 5/6/25.
//

import Foundation
import Combine

@MainActor
final class WelcomeFlowViewModel: ObservableObject {
    private let locationManager = LocationManager()
    private let motionManager = MotionManager()
    private let healthKitManager: HealthKitManager
    
    private var cancellables = Set<AnyCancellable>()
    
   
    @Published var isRequestHealthPermisson: Bool = false
    @Published var isRequestLocationPermisson: Bool = false
    @Published var isRequestMotionPermisson: Bool = false
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        
        healthKitManager.permissionResult
            .sink { _ in
                self.isRequestHealthPermisson = true
            }
            .store(in: &cancellables)
        
        motionManager.permissionResult
            .sink { _ in
                self.isRequestMotionPermisson = true
            }
            .store(in: &cancellables)
        
        locationManager.permissionResult
            .sink { value in
                print("===>>>  locationManager.permissionResult", value)
                self.isRequestLocationPermisson = true
            }
            .store(in: &cancellables)
    }
    
    func requestHealthPermisson() {
        healthKitManager.requestAuthorization()
    }
    
    func requestLocationPermisson() {
        locationManager.requestPermission()
    }
    
    func requestMotionPermisson() {
        motionManager.requestMotionPermission()
    }
}
