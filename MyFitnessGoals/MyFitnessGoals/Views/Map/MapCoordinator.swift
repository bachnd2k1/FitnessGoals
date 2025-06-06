//
//  MapCoordinator.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import Foundation
import MapKit


final class MapCoordinator: NSObject, MKMapViewDelegate {
    let parent: MapViewUI

    init(_ parent: MapViewUI) {
        self.parent = parent
    }

    // Annotation circle view for start and finish cursor. Having ciccle and image.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = LocationAnnotationView(annotation: annotation, reuseIdentifier: "custom")

        switch annotation.title {
        case "Start":
            let image = UIImage(named: "start")
            annotationView.image = image
            annotationView.backgroundColor = .black
            annotationView.layer.borderColor = UIColor.white.cgColor
        case "Finish":
            let image = UIImage(named: "finish")
            annotationView.image = image
            annotationView.backgroundColor = .gray
            annotationView.layer.borderColor = UIColor.black.cgColor
        default: break
        }

        return annotationView
    }

    // polyline from route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .orange
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    @objc func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            parent.mapView.mapType = .standard
        case 1:
            parent.mapView.mapType = .satellite
        case 2:
            parent.mapView.mapType = .hybrid
        default:
            break
        }
    }
}
