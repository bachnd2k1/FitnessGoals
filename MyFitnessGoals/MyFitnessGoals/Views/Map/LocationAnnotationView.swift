//
//  LocationAnnotationView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI
import MapKit

class LocationAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))
            layer.cornerRadius = 12.5
            layer.borderWidth = 2
        }
    }
}
