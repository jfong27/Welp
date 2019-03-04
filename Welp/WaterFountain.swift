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
    var fountainId : String
    var latitude : Double
    var longitude : Double
    var avgRating : Double
    var reviews : [Review]
    var inService : Bool
    var name : String
    
    var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title : String? {
        return name
    }
    
    var subtitle: String? {
        if inService {
            return "In Service"
        } else {
            print("Hello")
            return "Out of Service"
        }
    }
    
    let ref : DatabaseReference?
    
    init(fountainId: String, latitude: Double, longitude: Double,
         avgRating: Int, name: String, inService: Bool) {
        self.fountainId = fountainId
        self.latitude = latitude
        self.longitude = longitude
        self.avgRating = Double(avgRating)
        self.name = name
        self.inService = inService
        self.reviews = []
        ref = nil
        super.init()
    }
    
    init(key: String, snapshot: DataSnapshot) {

        fountainId = key
        
        print(key)
        print(snapshot)

        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]

        
        latitude = snapvalues["latitude"] as? Double ?? 0.0
        longitude = snapvalues["longitude"] as? Double ?? 0.0
        avgRating = 0.0
        name = snapvalues["description"] as? String ?? "Water"
        inService = snapvalues["inService"] as? Bool ?? false
        reviews = []
        
        
        ref = snapshot.ref
        super.init()
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "inService": inService,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
    
    
    
}

