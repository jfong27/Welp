//
//  ViewController.swift
//  Welp
//
//  Created by Jason Fong on 1/15/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var featuredIn: UILabel!
    
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters 
            locationManager.startUpdatingLocation()
        }
        
        searchBar.alpha = 1.0
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor.clear
    }
    
    @IBAction func mapButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "mapSegue", sender: self)
    }
    
    @IBAction func profileButton(_ sender: Any) {
        self.performSegue(withIdentifier: "profSegue", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
            
        }
        
    }

    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            featuredIn.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let city = placemark.locality {
                    featuredIn.text = "Search for Water in San Luis Obispo"
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.featuredIn.text = "Search for Water in Paris"
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                        self.featuredIn.text = "Search for Water in Hong Kong"
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
                        self.featuredIn.text = "Search for Water in " + city
                    }
                    
                }
            } else {
                featuredIn.text = "No Matching Addresses Found"
            }
        }
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("HI")
        searchBar.keyboardAppearance = .dark
        
    }
    
}

