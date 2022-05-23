//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Владимир on 29.09.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "placeIdentifier"
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    

    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var distanceToPlaceLabel: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var transportTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var dirBackgroundView: UIView!
    @IBOutlet weak var kmTextLabel: UILabel!
    @IBOutlet weak var minTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        addressLabel.text = ""
        setupMapView()
        checkLocationServices()
        
        
        
    }
        
    private func setupMapView() {
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        } else if incomeSegueIdentifier == "getAddress" {
            showUserLocation()
            routeButton.isHidden = true
            transportTypeSegmentedControl.isHidden = true
        }
        
        doneButton.backgroundColor = UIColor(named: "mySystemColor")
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 8
        
        routeButton.backgroundColor = UIColor(named: "mySystemColor")
        routeButton.clipsToBounds = true
        routeButton.layer.cornerRadius = 8
        
        transportTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                                             for: .selected)
        
        dirBackgroundView.clipsToBounds = true
        dirBackgroundView.layer.cornerRadius = 5
        dirBackgroundView.isHidden = true
    }
    
    private func resetMapView(withNew directions: MKDirections) { 
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    
    @IBAction func doneButtonPressed() {
        
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func goButtonPressed() {
      //  self.mapView.removeOverlays(self.mapView.overlays)
        getDirections()
        dirBackgroundView.isHidden = false
    }
    
    @IBAction func closeMap() {
        dismiss(animated: true)
    }
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        showUserLocation()
    }
    
    private func showUserLocation() {
        
        checkLocationAuthorization()
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingUserLocation() {
        
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 100 else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
    
        directions.calculate { response, error in
            if let error = error { print(error); return }
            guard let response = response else { self.showAlert(title: "Error", message: "Direction is not available"); return }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                self.distanceToPlaceLabel.text = "\(distance) км"
                self.travelTimeLabel.text = "\(timeInterval) мин"
                print("distance: \(distance). timeInterval: \(timeInterval)")
            }
            
        }
    }
    
    private func createDirectionsRequest(from cordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCordinate = placeCoordinate else { return nil }
        
        let startingLocation = MKPlacemark(coordinate: cordinate)
        let destination = MKPlacemark(coordinate: destinationCordinate)
    
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        
        switch transportTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            request.transportType = .automobile
        case 1:
            request.transportType = .walking
        default:
            request.transportType = .any
        }
        return request
    }
    
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)

        
    }
    
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            
            annotationView?.rightCalloutAccessoryView = imageView
            
        }
        
        return annotationView
    
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
        
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let streetName = placemark?.thoroughfare
            let houseNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && houseNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(houseNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(named: "mySystemColor")
        
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationAuthorization()
        
        if incomeSegueIdentifier == "getAddress" {
            showUserLocation()
        }
    }
    
}
