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
                self.isRequestLocationPermisson = true
            }
            .store(in: &cancellables)
    }
    
    func requestHealthPermisson() {
        DispatchQueue.main.async {
            self.healthKitManager.requestAuthorization()
        }
    }
    
    func requestLocationPermisson() {
        DispatchQueue.main.async {
            self.locationManager.requestPermission()
        }
    }
    
    func requestMotionPermisson() {
        DispatchQueue.main.async {
            self.motionManager.requestMotionPermission()
        }
    }
    
    func saveUserInfo(age: Int?, gender: String?, weight: Int?, height: Int?) {
        if let age = age {
            UserDefaults.standard.save(age, for: .age)
        }
        if let gender = gender {
            UserDefaults.standard.save(gender, for: .gender)
        }
        if let weight = weight {
            UserDefaults.standard.save(weight, for: .weight)
        }
        if let height = height {
            UserDefaults.standard.save(height, for: .height)
        }
    }
}
