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
import GeoFire

//NOTE: CLFloor can tell you what floor you are on.

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var didSetLocation = false
    var dbRef: DatabaseReference!
    var geoFire : GeoFire?
    var regionQuery : GFRegionQuery?
    var fountainToPass : WaterFountain?
    var lat = 0.0
    var lon = 0.0
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var coordLabel: UILabel!
    
    override func viewDidLoad() {
        print("VIEW DID LOAD")
        super.viewDidLoad()
        dbRef = Database.database().reference().child("fountains")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        map.frame = self.view.bounds;
        
        
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
        
        centerElements()
        
        coordLabel.isHidden = true
        marker.isHidden = true
        cancelButton.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("VIEW WILL APPEAR")
        self.navigationController?.isNavigationBarHidden = true
        coordLabel.isHidden = true
        marker.isHidden = true
        cancelButton.isHidden = true
        
        addButton.setAttributedTitle(NSAttributedString(string: "Add New Water Fountain"), for: .normal)
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
        lat = mapView.centerCoordinate.latitude
        lon = mapView.centerCoordinate.longitude
        let latStr = String(lat).prefix(8)
        let lonStr = String(lon).prefix(8)
        coordLabel.text =  "(" + latStr + ", " + lonStr + ")"
        
        updateRegionQuery()
    }
    
    private func updateRegionQuery() {
        
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        map.removeAnnotations(map.annotations)
        
        regionQuery = geoFire?.query(with: map.region)
        regionQuery?.observe(.keyEntered, with: {(key, location) in
            self.dbRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: {snapshot in
                
                if key.count == 10 {
                    let newFountain = WaterFountain(key: key, snapshot: snapshot)
                    self.addFountain(newFountain)
                }
            })
        })
    }
    
    private func addFountain(_ fountain : WaterFountain) {
        DispatchQueue.main.async {
            self.map.addAnnotation(fountain)
        }
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
            self.performSegue(withIdentifier: "NewReviewSegue", sender: self)
        }
        
        
    }
    
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        map.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is WaterFountain {
            let annotationView = MKPinAnnotationView()
        
            annotationView.pinTintColor = .blue
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) as UIButton
            
            annotationView.rightCalloutAccessoryView = button
            return annotationView
        }
        
        return nil
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewReviewSegue" {
            let vc = segue.destination as! NewReviewVC
            vc.latPassed = map.centerCoordinate.latitude
            vc.lonPassed = map.centerCoordinate.longitude
        }
        if segue.identifier == "FountainDetailSegue" {
            let vc = segue.destination as! FountainDetailVC
            vc.fountainPassed = self.fountainToPass
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView{
            self.fountainToPass = view.annotation as? WaterFountain
            self.performSegue(withIdentifier: "FountainDetailSegue", sender: self)
            
        }
    }
    
    func centerElements() {
        addButton.center.x = self.view.center.x
        addButton.center.y = self.view.center.y/6 + 50
        mapTypeSelector.center.x = self.view.center.x
        mapTypeSelector.center.y = self.view.center.y/6
        coordLabel.center.x = self.view.center.x
        coordLabel.center.y = self.view.center.y/6 + 83
        marker.center = self.view.center
        cancelButton.center.y = coordLabel.center.y
        cancelButton.center.x = coordLabel.center.x + 115
        
        mapTypeSelector.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        self.view.bringSubviewToFront(addButton)
        self.view.bringSubviewToFront(mapTypeSelector)
        self.view.bringSubviewToFront(cancelButton)
        self.view.bringSubviewToFront(marker)
        self.view.bringSubviewToFront(coordLabel)
    }

}
