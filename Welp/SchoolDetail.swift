//
//  SchoolDetail.swift
//  Welp
//
//  Created by Jason Fong on 2/27/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit

class SchoolDetail : UIViewController {
    var schoolPassed : School?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = schoolPassed!.name
        let city = schoolPassed!.city
        let state = schoolPassed!.state
        let zip = schoolPassed!.zip
        locLabel.text = "\(city), \(state) \(zip)"
        contactLabel.text = "Contact: \(schoolPassed!.contactEmail)"
    }
    @IBAction func exitButton(_ sender: Any) {
        self.performSegue(withIdentifier: "schoolMapSegue", sender: self)
    }
}

