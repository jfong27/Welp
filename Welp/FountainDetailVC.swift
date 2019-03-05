//
//  FountainDetailVC.swift
//  Welp
//
//  Created by Jason Fong on 3/3/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit

class FountainDetailVC : UIViewController {
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    var fountainPassed : WaterFountain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ratingStr = String(fountainPassed!.avgRating).prefix(3)
        descLabel.text = "\(fountainPassed!.name) (\(ratingStr) / 5)"
        
        let avgTemp = fountainPassed!.avgTemp
        if avgTemp >= 81 {
            tempLabel.text = "Users say the water here is usually burning hot!"
        } else if avgTemp >= 61 {
            tempLabel.text = "Users say the water here is usually warm"
        } else if avgTemp >= 41 {
            tempLabel.text = "Users say the water here is usually room temperature"
        } else if avgTemp >= 21 {
            tempLabel.text = "Users say the water here is usually cool"
        } else {
            tempLabel.text = "Users say the water here is usually ice cold"
        }        
        
        arrangeElements()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReviewSegue" {
            let vc = segue.destination as! AddReviewVC
            vc.passedFountain = self.fountainPassed!
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addReviewButton(_ sender: Any) {
        self.performSegue(withIdentifier: "AddReviewSegue", sender: self)
    }
    
    private func arrangeElements() {
        descLabel.center.x = self.view.center.x
        descLabel.center.y = self.view.center.y/3
        descLabel.adjustsFontSizeToFitWidth = true
        tempLabel.adjustsFontSizeToFitWidth = true
    }
}
