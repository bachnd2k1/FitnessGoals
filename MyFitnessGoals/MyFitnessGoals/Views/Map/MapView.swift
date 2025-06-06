//
//  MapView.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 27/01/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    let mapType: MapType
    let startLocation: CLLocation?
    let route: [CLLocation]
    let endLocation: CLLocation?
    @Binding var isFullScreen: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            MapViewUI(mapType: mapType,
                      startLocation: startLocation,
                      endLocation: endLocation,
                      route: route)
            .edgesIgnoringSafeArea(isFullScreen ? .all : .init()) // Mở rộng toàn màn hình
            .frame(maxWidth: .infinity, maxHeight: isFullScreen ? .infinity : 400)
            .cornerRadius(10)
            .padding(.vertical)
            .opacity(0.7)
            .onTapGesture {
                withAnimation {
                    isFullScreen.toggle()
                }
            }
            
            if isFullScreen {
                Button {
                    withAnimation {
                        isFullScreen = false
                    }
                } label: {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)

                        Image(systemName: "xmark")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 10)
                .padding()
            }
        }
    }
}

struct MapViewUI: UIViewRepresentable {
    let mapView = MKMapView()
    let mapType: MapType
    let regionRadius: CLLocationDistance = 1500
    var startLocation: CLLocation?
    var endLocation: CLLocation?
    var route: [CLLocation]
    
    func makeUIView(context: UIViewRepresentableContext<MapViewUI>) -> MKMapView {
        let region = getRouteCenterRegion(mapView: mapView)
        mapView.setRegion(region, animated: false)
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.delegate = context.coordinator
        mapView.register(LocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // Thêm chế độ chuyển đổi bản đồ
        addMapTypeSelector(to: mapView, context: context)
        if let startPoint { mapView.addAnnotation(startPoint) }
        if let endPoint { mapView.addAnnotation(endPoint) }
        mapView.addOverlay(polyline)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapViewUI>) {
        
        let region = getRouteCenterRegion(mapView: uiView)
        uiView.setRegion(region, animated: false)
        
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        if let startPoint { uiView.addAnnotation(startPoint) }
        if let endPoint { uiView.addAnnotation(endPoint) }
        uiView.addOverlay(polyline)
    }
    
    func makeCoordinator() -> MapCoordinator {
        .init(self)
    }
    
    private func addMapTypeSelector(to mapView: MKMapView, context: UIViewRepresentableContext<MapViewUI>) {
        let segmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(context.coordinator, action: #selector(context.coordinator.mapTypeChanged(_:)), for: .valueChanged)
        segmentedControl.backgroundColor = .white
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 10),
            segmentedControl.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    
    private func getRouteCenterRegion(mapView: MKMapView) -> MKCoordinateRegion {
        let approximateRouteCenterLatitude = ((endLocation?.coordinate.latitude ?? 0) + (startLocation?.coordinate.latitude ?? 0)) / 2
        let approximateRouteCenterLongitude = ((endLocation?.coordinate.longitude ?? 0) + (startLocation?.coordinate.longitude ?? 0)) / 2
        let routeCenterLocation = CLLocationCoordinate2D(
            latitude: approximateRouteCenterLatitude,
            longitude: approximateRouteCenterLongitude)
        switch mapType {
        case .stationary:
            return MKCoordinateRegion(
                center: routeCenterLocation,
                latitudinalMeters: regionRadius,
                longitudinalMeters: regionRadius)
        case .moving:
            return MKCoordinateRegion(
                center: mapView.userLocation.coordinate,
                latitudinalMeters: regionRadius,
                longitudinalMeters: regionRadius)
        }
    }
}

extension MapViewUI {
    var startPoint: MKPointAnnotation? {
        if let startLocation {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.title = "Start"
            startAnnotation.coordinate = startLocation.coordinate
            return startAnnotation
        }
        return nil
    }
    var endPoint: MKPointAnnotation? {
        if let endLocation {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.title = "Finish"
            endAnnotation.coordinate = endLocation.coordinate
            return endAnnotation
        }
        return nil
    }
    var polyline: MKPolyline {
        MKPolyline(
            coordinates: route.map { $0.coordinate },
            count: route.count)
    }
}

enum MapType {
    case stationary
    case moving
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapViewUI(
            mapType: .stationary,
            startLocation: PersistenceController.mockCoords.first,
            endLocation: PersistenceController.mockCoords.last,
            route: PersistenceController.mockCoords)
    }
}
