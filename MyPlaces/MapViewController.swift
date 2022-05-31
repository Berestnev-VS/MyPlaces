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
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.makeDir(response: self.mapManager.response)
            self.dirBackgroundView.isHidden = false
        }
    }
    
    func makeDir(response: MKDirections.Response) {
        
        var routesArray: [MKRoute] = []
        
        for route in response.routes {
            routesArray.append(route)
        }
        
        routesArray = routesArray.sorted { $0.expectedTravelTime < $1.expectedTravelTime }
        
        self.distanceToPlaceLabel.text = String(format: "%.1f", routesArray[0].distance / 1000)
        self.travelTimeLabel.text = String(format: "%.1f", routesArray[0].expectedTravelTime / 60)
        
    }
    
    @IBAction func changeTransportType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapManager.transportType = .automobile
        case 1:
            mapManager.transportType = .walking
        default:
            mapManager.transportType = .any
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
    
    func mapView(_ mapView: MKMapView,  DidChangeAnimated animated: Bool) {
        
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
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        mapManager.checkLocationAuthorization(mapView: mapView)
        
        if incomeSegueIdentifier == "getAddress" {
            mapManager.showUserLocation(mapView: mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = UIColor(named: "mySystemColor")
        
        return renderer
    }
    
}
