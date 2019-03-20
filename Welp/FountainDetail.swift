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
            cell.descLabel.text = "\(fountainPassed!.name)  ( \(fountainPassed!.avgRating) / 5 )"
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
                if let images = value?["images"] as? [String: String] {
                    if let imgC = images["C"] {
                        cell.leftImage.downloaded(from: images["A"] ?? "")
                        cell.middleImage.downloaded(from: images["B"] ?? "")
                        cell.rightImage.downloaded(from: imgC)
                    } else if let imgB = images["B"] {
                        cell.leftImage.downloaded(from: images["A"] ?? "")
                        cell.rightImage.downloaded(from: imgB)
                    } else if let imgA = images["A"] {
                        cell.middleImage.downloaded(from: imgA)
                    }
                }
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
                cell.leftImage.makeCircle()
                cell.middleImage.makeCircle()
                cell.rightImage.makeCircle()
                let pictureTap1 = UITapGestureRecognizer(target: self, action: #selector(FountainDetail.imageTapped))
                let pictureTap2 = UITapGestureRecognizer(target: self, action: #selector(FountainDetail.imageTapped))
                let pictureTap3 = UITapGestureRecognizer(target: self, action: #selector(FountainDetail.imageTapped))
                cell.leftImage.addGestureRecognizer(pictureTap1)
                cell.middleImage.addGestureRecognizer(pictureTap2)
                cell.rightImage.addGestureRecognizer(pictureTap3)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        print(reviewId!)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddReviewSegue" {
            let vc = segue.destination as! AddReviewVC
            vc.passedFountain = fountainPassed
        } else if segue.identifier == "CompassSegue" {
            print("A")
            let vc = segue.destination as! CompassVC
            print("B")
            vc.locPassed = fountainPassed?.coordinate
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
        
        let alertController : UIAlertController = UIAlertController(title: "How do you want to get there?", message: "Select Compass or Maps", preferredStyle: .actionSheet)
        
        let compassAction : UIAlertAction = UIAlertAction(title: "Compass", style: .default, handler: {(cameraAction) in
            self.performSegue(withIdentifier: "CompassSegue", sender: self)
        })
        
        let mapsAction : UIAlertAction = UIAlertAction(title: "Maps", style: .default, handler: {(libraryAction) in
            
            let waterPlacemark = MKPlacemark(coordinate: (self.fountainPassed?.coordinate)!)
            let waterMapItem = MKMapItem(placemark: waterPlacemark)
            waterMapItem.name = self.fountainPassed?.name
            
            
            let mapItems = [waterMapItem]
            let directionOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            MKMapItem.openMaps(with: mapItems, launchOptions: directionOptions)

            
        
        })
        
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
            print("Cancel action was pressed")
        })
        
        
        alertController.addAction(compassAction)
        
        alertController.addAction(mapsAction)
        
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

    
}
