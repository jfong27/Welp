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
                      UITableViewDelegate, UITableViewDataSource,
                      UITextFieldDelegate {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var featuredIn: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    lazy var geocoder = CLGeocoder()
    var listFountains : [WaterFountain] = []
    var geoFire : GeoFire?
    var dbRef : DatabaseReference!
    var fountainToPass : WaterFountain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.locationManager.requestWhenInUseAuthorization()
        self.hideKeyboard()
        searchField.keyboardType = .numbersAndPunctuation
        navigationController?.navigationBar.isHidden = true
        dbRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters 
            locationManager.startUpdatingLocation()
        }

        tableView.dataSource = self
        tableView.delegate = self
        
//        searchBar.alpha = 1.0
//        searchBar.backgroundColor = UIColor.clear
//        searchBar.backgroundImage = UIImage()
//        searchBar.barTintColor = UIColor.clear
//        searchBar.delegate = self
        
        featuredIn.adjustsFontSizeToFitWidth = true
        
        organizeElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        populateFountainsList()
    }
    
    
    private func populateFountainsList() {
        let regionQuery = geoFire?.query(at: locationManager.location ?? CLLocation(latitude: 50, longitude: 90), withRadius: 2.0)
        regionQuery?.observe(.keyEntered, with: {(key, location) in
            self.dbRef.child("fountains").queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: {snapshot in
                
                let newFountain = WaterFountain(key: key, snapshot: snapshot)
                // The reason for adding and removing is to remove the old version
                // of the fountain and replace it with one with updated avg rating,
                // in service, etc.
                if self.listFountains.contains(newFountain) {
                    self.listFountains.remove(at: self.listFountains.firstIndex(of: newFountain)!)
                }
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
    

    
    private func organizeElements() {
        self.view.sendSubviewToBack(tableView)
//        self.view.bringSubviewToFront(searchBar)
    }
    
    //Table view delegate/datasource protocol conformation funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFountains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WFCell", for: indexPath) as! WFCell
        
        let fountain = listFountains[indexPath.row]
        
        let reviewId = fountain.reviews[0]
        dbRef.child("reviews/\(reviewId)/images").observeSingleEvent(of: .value, with:
            { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let imageLink = value?["A"] as? String ?? ""
                cell.thumbImage.downloaded(from: imageLink)
                cell.thumbImage.clipsToBounds = true
                cell.thumbImage.contentMode = .scaleAspectFill
                cell.thumbImage.layer.cornerRadius = cell.thumbImage.frame.size.height/2
        })
        cell.nameLabel.text = "\(fountain.name)  ( \(fountain.avgRating) / 5 )"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FountainDetailSegue" {
            let vc = segue.destination as! FountainDetail
            vc.fountainPassed = fountainToPass
        } else if segue.identifier == "ReviewTableSegue" {
            let vc = segue.destination as! FountainDetail
            vc.fountainPassed = fountainToPass
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        fountainToPass = listFountains[(indexPath?.row)!]
        
        self.performSegue(withIdentifier: "ReviewTableSegue", sender: self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.text)
        return true
    }
    
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.keyboardAppearance = .dark
//
//    }
    

}

