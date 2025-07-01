//
//  SelectWorkoutViewModel.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 25/6/25.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class SelectWorkoutViewModel: ObservableObject {
    private let locationManager = LocationManager()
    private let motionManager = MotionManager()
    
    @Published var locationAccessIsDenied: Bool = false
    @Published var locationAccessNotDetermine: Bool = false
    @Published var locationAccessThrowsError: Bool = false
    
    @Published var motionAccessIsDenied: Bool = false
    @Published var motionAccessThrowsError: Bool = false
    @Published var motionAccessNotDetermine: Bool = false
    
    
    init () {
        motionManager.$motionAccessIsDenied
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessIsDenied)

        motionManager.$motionAccessNotDetermine
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessNotDetermine)

        motionManager.$motionAccessThrowsError
            .receive(on: DispatchQueue.main)
            .assign(to: &$motionAccessThrowsError)
        
        locationManager.$locationAccessIsDenied
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationAccessIsDenied)
        
        locationManager.$locationAccessNotDetermine
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationAccessNotDetermine)
        
        locationManager.$locationAccessThrowsError
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationAccessThrowsError)
    }
}
