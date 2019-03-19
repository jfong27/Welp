//
//  FountainDetail.swift
//  Welp
//
//  Created by Jason Fong on 3/16/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MapKit

class FountainDetail : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fountainPassed : WaterFountain?
    var dbRef : DatabaseReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = Database.database().reference()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fountainPassed?.reviews.count ?? 0) + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FountainDetailCell", for: indexPath) as! FountainDetailCell
            let avgTemp = fountainPassed?.avgTemp ?? 50
            cell.descLabel.lineBreakMode = .byWordWrapping
            cell.descLabel.numberOfLines = 0
            cell.descLabel.text = fountainPassed?.name
            cell.tempLabel.text = Helper.tempDescription(temp: avgTemp)
            cell.tempLabel.adjustsFontSizeToFitWidth = true
            cell.tempLabel.numberOfLines = 2
            if !(fountainPassed?.inService)! {
                cell.serviceLabel.text = "Out of Service"
                cell.serviceLabel.adjustsFontSizeToFitWidth = true
                cell.serviceLabel.numberOfLines = 1
                cell.serviceImage.image = UIImage(named: "redX")
            }
            if !(fountainPassed?.hasFiller)! {
                cell.fillerLabel.text = "Bottle Filler"
                cell.fillerLabel.adjustsFontSizeToFitWidth = true
                cell.fillerLabel.numberOfLines = 1
                cell.fillerImage.image = UIImage(named: "redX")
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell

        let reviewId = fountainPassed?.reviews[indexPath.row - 1]
        
        
        dbRef.child("reviews").child(reviewId!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let review = value?["review"] as? String ?? ""
                let rating = value?["rating"] as? Int ?? 0
                let userId = value?["user"] as? String ?? ""
            self.dbRef.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot2)
                in
                let value2 = snapshot2.value as? NSDictionary
                let firstName = value2?["firstName"] as? String ?? "Welper"
                let lastName = value2?["lastName"] as? String ?? ""
                cell.userLabel.text = "- \(firstName) \(lastName)"
            })
            cell.ratingControl.rating = rating
            cell.ratingControl.canChange = false
            cell.reviewLabel.text = "\"\(review)\""
            cell.reviewLabel.lineBreakMode = .byWordWrapping
            cell.reviewLabel.numberOfLines = 0
            
        }) { (error) in
            print(error.localizedDescription)
        }
//
//        dbRef.child("reviews").queryOrdered(byChild: "user").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { snapshot in
//            var numReviews = 0
//            let fetchedList = snapshot.children.allObjects
//            numReviews = fetchedList.count
//
//            if numReviews == 1 {
//                self.numReviewsLabel.text = String(numReviews) + " Review"
//            } else {
//                self.numReviewsLabel.text = String(numReviews) + " Reviews"
//            }
//        })
        
        print(reviewId!)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReviewSegue" {
            let vc = segue.destination as! AddReviewVC
            vc.passedFountain = fountainPassed
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func addReview(_ sender: Any) {
        self.performSegue(withIdentifier: "AddReviewSegue", sender: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func getDirections(_ sender: Any) {
        let waterPlacemark = MKPlacemark(coordinate: (fountainPassed?.coordinate)!)
        let waterMapItem = MKMapItem(placemark: waterPlacemark)
        waterMapItem.name = fountainPassed?.name
        
        
        let mapItems = [waterMapItem]
        let directionOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        MKMapItem.openMaps(with: mapItems, launchOptions: directionOptions)
    }
}
