//
//  School.swift
//  Welp
//
//  Created by Jason Fong on 2/26/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class School : NSObject, MKAnnotation {
    
    var name : String
    var city : String
    var state : String
    var zip : String
    var contactEmail : String
    var latitude : Double
    var longitude : Double
    
    let ref : DatabaseReference?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return city
    }
    
    init(name: String, city: String, specialty: String) {
        self.name = name
        self.city = city
        self.state = "N/A"
        self.zip = "N/A"
        self.contactEmail = "N/A"
        self.latitude = 0
        self.longitude = 0
        ref = nil
        
        super.init()
    }
    
    init(key: String,snapshot: DataSnapshot) {
        name = key
        
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        
        city = snapvalues["city"] as? String ?? "N/A"
        state = snapvalues["state"] as? String ?? "N/A"
        zip = snapvalues["zip"] as? String ?? "N/A"
        contactEmail = snapvalues["contact_email"] as? String ?? "N/A"
        latitude = snapvalues["latitude"] as? Double ?? 0.0
        longitude = snapvalues["longitude"] as? Double ?? 0.0
        
        ref = snapshot.ref
        
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "name" : name,
            "city" : city,
            "state" : state,
            "zip" : zip,
            "contactEmail" : contactEmail,
            "latitude" : latitude,
            "longitude" : longitude
        ]
    }
}
