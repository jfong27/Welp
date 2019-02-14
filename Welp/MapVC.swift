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
    
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let startRegion = MKCoordinateRegion(center: locValue, span: span)
        
        map.setRegion(startRegion, animated: true)
        
    }
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        map.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!
    }
}
