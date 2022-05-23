//
//  MapManager.swift
//  MyPlaces
//
//  Created by Владимир on 23.05.2022.
//

import MapKit
import UIKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    private func setupPlaceMark(place: Place, mapView: MKMapView) {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = "\(place.category!), \(place.rating) \u{2605}"
            
            guard let placeMarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            
            self.placeCoordinate = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    private func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization(mapView: mapView)
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            closure()
            
        }
    }
    
    private func checkLocationAuthorization(mapView: MKMapView) {
    
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .authorizedAlways:
            break
            
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
//            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
            
        case .denied:
            if CLLocationManager.locationServicesEnabled() {
               showAlert(title: "Location detection for this app is disabled", message: "Go to \"Settings\" -> \"MyPlaces\" -> \"Location\", and select \"Always\" or \"When in use\"")
            } else {
                showAlert(title: "Location services is disabled", message: "Turn on location services in your device settings")
            }
            break
            
        case .restricted:
            showAlert(title: "Location Service restrictions on your device", message: "Go to \"Settings\" -> \"General\" -> \"Restrictions\"")
            break
            
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
            print("New case is available")
            break
        }
    }

    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}
