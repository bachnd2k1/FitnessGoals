//
//  WatchNavigationRouter.swift
//  MyFitness Watch App
//
//  Created by Nghiem Dinh Bach on 9/6/25.
//

import Foundation
import Combine
import SwiftUI

class WatchNavigationRouter: ObservableObject {
    
    // Sử dụng @Published gây re-render UI
    
    let measurementPublisher = PassthroughSubject<WorkoutMeasurement, Never>()
    let isPairedPublisher = CurrentValueSubject<Bool, Never>(false)
    
    @Published var isLocationPermission: Bool = true
    @Published var isMotionPermission: Bool = true
    
    func updateMetrics(latestMeasurement: WorkoutMeasurement) {
        measurementPublisher.send(latestMeasurement)
    }
    
    func updateLocationPermission(isLocationPermission: Bool) {
        self.isLocationPermission = isLocationPermission
    }
    
    func updateMotionPermission(isMotionPermission: Bool) {
        self.isMotionPermission = isMotionPermission
    }
    
    func updatePairingState(isPaired: Bool) {
        isPairedPublisher.send(isPaired)
    }
}
