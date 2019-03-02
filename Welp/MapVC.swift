//
//  MapVC.swift
//  Welp
//
//  Created by Jason Fong on 1/29/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import MapKit
import UIKit
import Firebase
import FirebaseDatabase

//NOTE: CLFloor can tell you what floor you are on.

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var didSetLocation = false
    var dbRef: DatabaseReference!
    var lat = 0.0
    var lon = 0.0
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var coordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dbRef = Database.database().reference()
        
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
        lat = mapView.centerCoordinate.latitude
        lon = mapView.centerCoordinate.longitude
        let latStr = String(lat).prefix(8)
        let lonStr = String(lon).prefix(8)
        coordLabel.text =  "(" + latStr + ", " + lonStr + ")"
    }
    
    @IBAction func addReview(_ sender: Any) {
        if ((addButton.titleLabel?.text!)!) == "Add New Water Fountain" {
            marker.isHidden = false
            coordLabel.isHidden = false
            cancelButton.isHidden = false
            
            addButton.setAttributedTitle(NSAttributedString(string: "Confirm Location"), for: .normal)
            addButton.setTitleColor(.white, for: .normal)
            
            Helper.vibrate()
        } else {
            uploadToFirebase(latitude: lat, longitude: lon)
        }
        
        
    }
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        map.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!
    }

    func uploadToFirebase(latitude: Double, longitude: Double) {

        var dict = [String:Any]()

        let id = 0

        dict.updateValue(id, forKey: "locationId")
        dict.updateValue(latitude, forKey: "latitude")
        dict.updateValue(longitude, forKey: "longitude")

        dbRef.child("locations")
             .child("waterFountains")
             .child(String(id)).setValue(dict)


    }

}
