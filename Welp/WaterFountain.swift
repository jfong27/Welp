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

class WaterFountain {
    var coordinates : MKPointAnnotation
    var description : String
    var rating : Int
    
    init(coordinates: MKPointAnnotation, description: String, rating: Int) {
        self.coordinates = coordinates
        self.description = description
        self.rating = rating
    }
    
}

