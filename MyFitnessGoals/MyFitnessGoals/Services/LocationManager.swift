//
//  LocationManager.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI
import UIKit

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var isRecording = false
    var previousLocation: CLLocation?
    let permissionResult = PassthroughSubject<Bool, Never>()
    @Published var locationAccessIsDenied: Bool = false
    @Published var locationAccessThrowsError: Bool = false
    @Published var locationAccessNotDetermine: Bool = false
    @Published var locationAccessError = ""
    @Published var locations: [CLLocation] = []
    @Published var distances: [Measurement<UnitLength>] = []
    @Published var speeds: [Measurement<UnitSpeed>] = []
    @Published var altitudes: [Measurement<UnitLength>] = []
    var startLocation: CLLocation? { locations.first }
    @Published var endLocation: CLLocation?
    @Published var totalDistance: CLLocationDistance = 0
    var distancePublisher: AnyPublisher<Measurement<UnitLength>, Never> {
        $distances.flatMap { distances in distances.publisher }.eraseToAnyPublisher()
    }
    var speedPublisher: AnyPublisher<Measurement<UnitSpeed>, Never> {
        $speeds.flatMap { speeds in speeds.publisher }.eraseToAnyPublisher()
    }
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        updatePermissionStatus()
    }
    
    func updatePermissionStatus() {
        let status = locationManager.authorizationStatus
        DispatchQueue.main.async {
            self.locationAccessIsDenied = (status == .denied || status == .restricted)
            self.locationAccessNotDetermine = (status == .notDetermined)
        }
    }
    
    func isLocationGranted() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse ||
        locationManager.authorizationStatus == .authorizedAlways
    }

    func requestPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("notDetermined")
        case .denied, .restricted:
#if os(iOS)
            openSettings()
#endif
            print(".denied, .restricted")
        case .authorizedWhenInUse, .authorizedAlways:
            print(".authorizedWhenInUse, .authorizedAlways")
        default:
            break
        }
        updatePermissionStatus()
    }

    #if os(iOS)
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    #endif
    
    func startLocationServices() {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            isRecording = true
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission not granted.")
        }
    }
    
    func stopLocationServices() {
        isRecording = false
        locationManager.stopUpdatingLocation()
        endLocation = locations.last
    }
    
    func reset() {
        locations.removeAll()
        distances.removeAll()
        speeds.removeAll()
        altitudes.removeAll()
        totalDistance = 0
        endLocation = nil
        previousLocation = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.locationAccessNotDetermine = (status == .notDetermined)
            self.locationAccessIsDenied = (status == .denied || status == .restricted)

            if status == .authorizedAlways || status == .authorizedWhenInUse {
                if self.isRecording {
                    self.locationManager.startUpdatingLocation()
                }
            }

            // Notify viewModel
            if status != .notDetermined {
                self.permissionResult.send(true)
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            guard let latest = locations.first else { return }
            self.locations.append(latest)
            if self.previousLocation == nil {
                self.previousLocation = latest
                self.distances.append(Measurement.init(value: 0, unit: UnitLength.meters))
            } else {
                let distance = self.previousLocation?.distance(from: latest) ?? 0
                self.totalDistance += distance
                self.distances.append(Measurement.init(value: self.totalDistance, unit: UnitLength.meters))
                self.previousLocation = latest
            }
            let speedValue = latest.speed > 0 ? latest.speed : 0
            self.speeds.append(Measurement.init(value: speedValue, unit: UnitSpeed.metersPerSecond))
            self.altitudes.append(Measurement.init(value: latest.altitude, unit: UnitLength.meters))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            guard let clError = error as? CLError else { return }
            switch clError {
            case CLError.denied, CLError.promptDeclined:
                self.locationAccessIsDenied = true
            default:
                self.locationAccessThrowsError = true
                self.locationAccessError = clError.localizedDescription
            }
        }
    }
}
