//
//  SchoolMap.swift
//  Welp
//
//  Created by Jason Fong on 2/23/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import MapKit
import UIKit
import Firebase
import FirebaseDatabase
import GeoFire

//NOTE: CLFloor can tell you what floor you are on.

class SchoolMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var dbRef : DatabaseReference?
    var geoFire : GeoFire?
    var regionQuery : GFRegionQuery?
    var schoolToPass : School?
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dbRef = Database.database().reference().child("schools")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        
        let locValue: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:35.2711716, longitude: -120.5787971)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let startRegion = MKCoordinateRegion(center: locValue, span: span)
        
        map.setRegion(startRegion, animated: true)
        
        updateRegionQuery()
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        print("REGION CHANGE")
        updateRegionQuery()
    }
    
    func updateRegionQuery() {
        print("UPDATE REGION QUERY")
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        regionQuery = geoFire?.query(with: map.region)
        print(regionQuery.unsafelyUnwrapped.region)
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            self.dbRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
                print("QUERY")
                let newSchool = School(key:key,snapshot:snapshot)
                self.addSchool(newSchool)
            })
        })
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("MAP DID UPDATE")
        mapView.setRegion(MKCoordinateRegion.init(center: (mapView.userLocation.location?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
        
    }
    
    func addSchool(_ school : School) {
        print("ADD SCHOOL")
        DispatchQueue.main.async {
            self.map.addAnnotation(school)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("VIEW FOR")
        if annotation is School {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = .red
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) as UIButton // button with info sign in it
            
            annotationView.rightCalloutAccessoryView = button
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView{
            self.schoolToPass = view.annotation as? School
            self.performSegue(withIdentifier: "SchoolDetailSegue", sender: self)
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SchoolDetailSegue" {
            let vc = segue.destination as! SchoolDetail
            
            vc.schoolPassed = self.schoolToPass
        }
    }

}
