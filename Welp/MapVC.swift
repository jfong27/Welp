//
//  MapVC.swift
//  Welp
//
//  Created by Jason Fong on 1/29/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import MapKit
import UIKit

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var didSetLocation = false
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var coordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        addButton.layer.cornerRadius = 7.0
        addButton.layer.masksToBounds = false
        addButton.layer.borderWidth = 0.0
        addButton.setTitleColor(.white, for: .normal)
        addButton = Helper.addShadowToButton(button: addButton)
        
        coordLabel.isHidden = true
        marker.isHidden = true
        cancelButton.isHidden = true
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        if !didSetLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let startRegion = MKCoordinateRegion(center: locValue, span: span)
        
            map.setRegion(startRegion, animated: true)
            didSetLocation = true
        }
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        coordLabel.isHidden = true
        marker.isHidden = true
        cancelButton.isHidden = true
        
        addButton.setAttributedTitle(NSAttributedString(string: "Add New Water Fountain"), for: .normal)
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(String(mapView.centerCoordinate.latitude))
        print(String(mapView.centerCoordinate.longitude))
        print("A")
        let lat = String(mapView.centerCoordinate.latitude).prefix(8)
        let lon = String(mapView.centerCoordinate.longitude).prefix(8)
        coordLabel.text =  "(" + lat + ", " + lon + ")"
    }
    
    @IBAction func addReview(_ sender: Any) {
        marker.isHidden = false
        coordLabel.isHidden = false
        cancelButton.isHidden = false
        
        addButton.setAttributedTitle(NSAttributedString(string: "Confirm Location"), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        
        Helper.vibrate()
        
    }
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        map.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!
    }
    
}
