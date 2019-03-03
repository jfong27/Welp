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

class ViewController: UIViewController, CLLocationManagerDelegate,
                      UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var featuredIn: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var geocoder = CLGeocoder()
    var listFountains : WaterFountains?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters 
            locationManager.startUpdatingLocation()
        }

        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.alpha = 1.0
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = UIColor.clear
        
        
        //FOR TESTING
        listFountains = WaterFountains(list: [WaterFountain(wfId: 5, latitude: 5.0, longitude: 5.0, rating: 5, name: "Test Fountain", inService: true)])
        
        organizeElements()
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
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
                        self.featuredIn.text = "Search for Water in " + city
                    }
                    
                }
            } else {
                featuredIn.text = "Search for Water in Your City"
            }
        }
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("HI")
        searchBar.keyboardAppearance = .dark
        
    }
    
    private func organizeElements() {
        self.view.sendSubviewToBack(tableView)
        self.view.bringSubviewToFront(searchBar)
    }
    
    
    //Table view delegate/datasource protocol conformation funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (listFountains?.list.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Cell for row at")
        let cell = tableView.dequeueReusableCell(withIdentifier: "WFCell", for: indexPath) as! WFCell
        
        let object = listFountains.unsafelyUnwrapped.list[indexPath.row]
        
        cell.nameLabel.text = object.name
        
        print(object.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row " + String(indexPath.row))
    }

}

