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
    
    var fountainPassed : WaterFountain?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ratingStr = String(fountainPassed!.avgRating).prefix(3)
        descLabel.text = "\(fountainPassed!.name) (\(ratingStr) / 5)"
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
    }
}
