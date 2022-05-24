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
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "placeIdentifier"
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, location: previousLocation) { currentLocation in
                
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
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

    }
        
    private func setupMapView() {
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        } else if incomeSegueIdentifier == "getAddress" {
            mapManager.showUserLocation(mapView: mapView)
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
    
    @IBAction func goToCurrentLocation(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func goButtonPressed() {
      //  self.mapView.removeOverlays(self.mapView.overlays)
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
        giveMeDistance(direction: mapManager.getDirections(for: mapView, previousLocation: { location in
            self.previousLocation = location
        }))
        dirBackgroundView.isHidden = false
    }
    
    func giveMeDistance(direction: MKDirections) {
        direction.calculate { response, error in
            
            if let error = error { print(error); return }
            
            guard let response = response else { return }
            
            for route in response.routes {
                
                self.distanceToPlaceLabel.text = String(format: "%.1f", route.distance / 1000)
                self.travelTimeLabel.text = String(format: "%.1f", route.expectedTravelTime / 60)

            }
        }
    }
    
    @IBAction func closeMap() {
        dismiss(animated: true)
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
    
    func changeTransportType() {
        let startingLocation = MKPlacemark(coordinate: mapManager.personCordinate!)
        let destination = MKPlacemark(coordinate: mapManager.placeCordinate!)
    
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
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.cancelGeocode()
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
        
        mapManager.checkLocationAuthorization(mapView: mapView)
        
        if incomeSegueIdentifier == "getAddress" {
            mapManager.showUserLocation(mapView: mapView)
        }
    }
    
}
