//
//  WaterFountains.swift
//  Welp
//
//  Created by Jason Fong on 3/2/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation

class WaterFountains {
    let list : [WaterFountain]
    
    private enum CodingKeys: String, CodingKey {
        case list
    }
    
    init(list: [WaterFountain]) {
        self.list = list
    }
    
}
