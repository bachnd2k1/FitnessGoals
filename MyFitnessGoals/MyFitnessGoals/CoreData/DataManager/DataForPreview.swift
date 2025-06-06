//
//  DataForPreview.swift
//  MyFitnessGoals
//
//  Created by Nghiem Dinh Bach on 10/3/25.
//

import Foundation
import CoreLocation
import CoreData

extension PersistenceController {
    static let previewPersistenceController = PersistenceController()
    
    static let mockCoords: [CLLocation] = [
        CLLocation(latitude: 37.33418, longitude: -122.01198),
        CLLocation(latitude: 37.33444, longitude: -122.01219),
        CLLocation(latitude: 37.33462, longitude: -122.01234),
        CLLocation(latitude: 37.33474, longitude: -122.01244),
        CLLocation(latitude: 37.33481, longitude: -122.0125),
        CLLocation(latitude: 37.33485, longitude: -122.01254),
        CLLocation(latitude: 37.33489, longitude: -122.0126),
        CLLocation(latitude: 37.33492, longitude: -122.01265),
        CLLocation(latitude: 37.33495, longitude: -122.01272),
        CLLocation(latitude: 37.33499, longitude: -122.01283),
        CLLocation(latitude: 37.33501, longitude: -122.01293),
        CLLocation(latitude: 37.33501, longitude: -122.01301),
        CLLocation(latitude: 37.33502, longitude: -122.0133),
        CLLocation(latitude: 37.33502, longitude: -122.01397),
        CLLocation(latitude: 37.33502, longitude: -122.014),
        CLLocation(latitude: 37.33503, longitude: -122.01417),
        CLLocation(latitude: 37.33514, longitude: -122.01417),
        CLLocation(latitude: 37.33772, longitude: -122.01416),
        CLLocation(latitude: 37.33776, longitude: -122.0054),
        CLLocation(latitude: 37.33447, longitude: -122.00546),
        CLLocation(latitude: 37.33353, longitude: -122.00569),
        CLLocation(latitude: 37.3327, longitude: -122.0059),
        CLLocation(latitude: 37.33038, longitude: -122.00586),
        CLLocation(latitude: 37.3304, longitude: -122.00603),
        CLLocation(latitude: 37.3304, longitude: -122.00619),
        CLLocation(latitude: 37.33035, longitude: -122.00652),
        CLLocation(latitude: 37.33022, longitude: -122.00681),
    ]
}
