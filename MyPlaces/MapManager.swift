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
    var response = MKDirections.Response()
    var placeCordinate: CLLocationCoordinate2D?
    var personCordinate: CLLocationCoordinate2D?
    
    var transportType = MKDirectionsTransportType()
    
    
    var directionsArray: [MKDirections] = []
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        
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
            
            self.placeCordinate = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization(mapView: mapView)
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            closure()
            
        }
    }
    
    func checkLocationAuthorization(mapView: MKMapView) {
    
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
    
    func showUserLocation(mapView: MKMapView) {
        
        checkLocationAuthorization(mapView: mapView)
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ())  {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return 
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        /* TODO: Не получается изменить request.transportType заранее.
         Маршрут строится в менеджере по реквесту.
         А мне нужно изменять реквест в контроллере до того, как построится маршрут.
         */
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        directions.calculate { response, error in
            
            if let error = error { print(error); return }
            
            guard let resp = response
            else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
                self.response = resp
            
            var routesArray: [MKRoute] = []
            
            for route in resp.routes {
                routesArray.append(route)
            }
        
            let sortedArray = routesArray.sorted { $0.expectedTravelTime < $1.expectedTravelTime }
            mapView.addOverlay(sortedArray[0].polyline)
            mapView.setVisibleMapRect(sortedArray[0].polyline.boundingMapRect, animated: true)
            print(sortedArray)
        }
    }

    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = transportType
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 100 else { return }
        closure(center)
        
        }
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
