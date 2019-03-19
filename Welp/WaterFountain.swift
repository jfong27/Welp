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
    var avgTemp : Double
    var inService : Bool
    var hasFiller : Bool
    var name : String
    var reviews : [String]

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
            return "Out of Service"
        }
    }
    
    let ref : DatabaseReference?
    
    init(fountainId: String, latitude: Double, longitude: Double,
         avgRating: Double, avgTemp: Double, name: String, inService: Bool,
         hasFiller: Bool, reviews : [String]) {
        self.fountainId = fountainId
        self.latitude = latitude
        self.longitude = longitude
        self.avgRating = Double(avgRating)
        self.avgTemp = Double(avgTemp)
        self.name = name
        self.inService = inService
        self.reviews = reviews
        self.hasFiller = hasFiller
        ref = nil
        super.init()
    }
    
    init(key: String, snapshot: DataSnapshot) {

        fountainId = key

        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]

        
        latitude = snapvalues["latitude"] as? Double ?? 0.0
        longitude = snapvalues["longitude"] as? Double ?? 0.0
        avgRating = snapvalues["avgRating"] as? Double ?? 0.0
        avgTemp = snapvalues["avgTemp"] as? Double ?? 0.0
        name = snapvalues["name"] as? String ?? "Water"
        inService = snapvalues["inService"] as? Bool ?? false
        hasFiller = snapvalues["hasBottleFiller"] as? Bool ?? false
        let reviewChild = snapvalues["reviews"] as? [String : Bool] ?? [:]
        
        reviews = Array(reviewChild.keys)
        
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
    
    override func isEqual(_ object: Any?) -> Bool {
        if let f = object as? WaterFountain {
            if f.fountainId == self.fountainId {
                return true
            }
        }
        
        return false
    }
    
    
    
}

