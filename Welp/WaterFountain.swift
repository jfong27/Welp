//
//  WaterFountain.swift
//  Welp
//
//  Created by Jason Fong on 1/29/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import MapKit
import UIKit
import Foundation
import FirebaseDatabase

class WaterFountain : NSObject, MKAnnotation {
    var wfId : Int
    var latitude : Double
    var longitude : Double
    var rating : Int
    var name : String
    var inService : Bool
    
    let ref : DatabaseReference?
    
    init(wfId: Int, latitude: Double, longitude: Double,
         rating: Int, name: String, inService: Bool) {
        self.wfId = wfId
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.name = name
        self.inService = inService
        self.rating = rating
        ref = nil
        super.init()
    }
    
//    init(key: Int,snapshot: DataSnapshot) {
//
//        wfId = key
//
//        let snaptemp = snapshot.value as! [Int : AnyObject]
//        let snapvalues = snaptemp[key] as! [Int : AnyObject]
//
//        rating = snapvalues["rating"] as? Int ?? "N/A"
//        state = snapvalues["state"] as? String ?? "N/A"
//        zip = snapvalues["zip"] as? String ?? "N/A"
//        contactEmail = snapvalues["contact_email"] as? String ?? "N/A"
//        latitude = snapvalues["latitude"] as? Double ?? 0.0
//        longitude = snapvalues["longitude"] as? Double ?? 0.0
//
//        ref = snapshot.ref
//
//        super.init()
//    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        if inService {
            return "In Service"
        } else {
            return "Out of Service"
        }
    }
    
}

