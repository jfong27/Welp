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
import GeoFire
import Firebase

class ViewController: UIViewController, CLLocationManagerDelegate,
                      UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var featuredIn: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var geocoder = CLGeocoder()
    var listFountains : [WaterFountain] = []
    var geoFire : GeoFire?
    var dbRef : DatabaseReference!
    var fountainToPass : WaterFountain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        navigationController?.navigationBar.isHidden = true
        dbRef = Database.database().reference().child("fountains")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        
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
        
        featuredIn.adjustsFontSizeToFitWidth = true
        
        populateFountainsList()
        organizeElements()
    }
    
    
    private func populateFountainsList() {

        let regionQuery = geoFire?.query(at: locationManager.location ?? CLLocation(latitude: 50, longitude: 90), withRadius: 2.0)
        regionQuery?.observe(.keyEntered, with: {(key, location) in
            self.dbRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: {snapshot in
                
                let newFountain = WaterFountain(key: key, snapshot: snapshot)
                self.listFountains.append(newFountain)
                self.tableView.reloadData()
            })
        })
        
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
        searchBar.keyboardAppearance = .dark
        
    }
    
    private func organizeElements() {
        self.view.sendSubviewToBack(tableView)
        self.view.bringSubviewToFront(searchBar)
    }
    
    //Table view delegate/datasource protocol conformation funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return listFountains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WFCell", for: indexPath) as! WFCell
        
        
        let fountain = listFountains[indexPath.row]
        
        
        cell.nameLabel.text = fountain.name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FountainDetailSegue" {
            let vc = segue.destination as! FountainDetailVC
            vc.fountainPassed = fountainToPass
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        fountainToPass = listFountains[(indexPath?.row)!]
        
        self.performSegue(withIdentifier: "FountainDetailSegue", sender: self)
    }

}

