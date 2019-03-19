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
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var fillerLabel: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    
    var fountainPassed : WaterFountain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ratingStr = String(fountainPassed!.avgRating).prefix(3)
        descLabel.text = "\(fountainPassed!.name) (\(ratingStr) / 5)"
        
        let avgTemp = fountainPassed!.avgTemp
        tempLabel.text = Helper.tempDescription(temp: avgTemp)
        
        if !((fountainPassed?.inService) ?? true) {
            serviceLabel.text = "Out of Service"
            serviceImage.image = UIImage(named: "redX")
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
