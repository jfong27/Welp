//
//  NewReviewVC.swift
//  Welp
//
//  Created by Jason Fong on 3/2/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GeoFire
import Firebase

class NewReviewVC : UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var bottleSwitch: UISwitch!
    @IBOutlet weak var bottleLabel: UILabel!
    @IBOutlet weak var serviceSwitch: UISwitch!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var ratingControl: RatingControl!
    
    let placeholderText = "Ex: This water fountain is awesome! It's always very clean" +
                          " and has crisp cool water every time! The water bottle " +
                          "filler is another added bonus. Highly recommend!"
    
    var latPassed : CLLocationDegrees?
    var lonPassed : CLLocationDegrees?
    
    var dbRef: DatabaseReference!
    var geoFire : GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.centerElements()
        self.dbRef = Database.database().reference()
        self.geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        
        reviewField.delegate = self
        reviewField.text = placeholderText
        reviewField.textColor = .lightGray
        
        tempSlider.maximumTrackTintColor = .cyan
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
        }
    }
    
    //TODO: Brand new fountain reviews will also upload to Fountains database and Geofire
    // Adding review to existing fountain will only upload to Re. 
    @IBAction func addReview(_ sender: Any) {
        
        print(ratingControl.rating)
        print("Gonna add this review to my review collection!")
        Helper.vibrate()

        let fountainId = Helper.randomAlphaNumericString(length: 10)
        let reviewId = Helper.randomAlphaNumericString(length: 10)

        addNewFountainToFirebase(fountainId: fountainId, reviewId: reviewId)
        addNewReviewToFirebase(fountainId: fountainId, reviewId: reviewId)
        
        Helper.playSoundAndVibrate()
        self.performSegue(withIdentifier: "ReviewDoneSegue", sender: self)
    }
    
    private func addNewFountainToFirebase(fountainId: String, reviewId: String) {
        var dict = [String:Any]()
        let fountainRef = self.dbRef.child("fountains")

        //Randomly generated string fountainId is the primary key

        dict.updateValue(fountainId, forKey: "fountainId")
        dict.updateValue(latPassed ?? 0, forKey: "latitude")
        dict.updateValue(lonPassed ?? 0, forKey: "longitude")
        dict.updateValue(Double(ratingControl.rating), forKey: "avgRating")
        dict.updateValue([reviewId], forKey: "reviews")
        dict.updateValue("Description", forKey: "description")
        dict.updateValue(Auth.auth().currentUser?.uid ?? 0, forKey: "user")

        fountainRef.child(fountainId).setValue(dict)
        self.geoFire?.setLocation(CLLocation(latitude: latPassed ?? 0,longitude:lonPassed ?? 0), forKey: fountainId)
    }
    
    private func addNewReviewToFirebase(fountainId: String, reviewId: String) {
        var dict = [String:Any]()
        let fountainRef = self.dbRef.child("reviews")
        
        //Randomly generated string fountainId is the primary key
        
        dict.updateValue(fountainId, forKey: "fountain")
        dict.updateValue("Description", forKey: "description")
        dict.updateValue(reviewField.text, forKey: "review")
        dict.updateValue(serviceSwitch.isOn, forKey: "inService")
        dict.updateValue(bottleSwitch.isOn, forKey: "hasBottleFiller")
        dict.updateValue(tempSlider.value, forKey: "temperature")
        dict.updateValue(ratingControl.rating, forKey: "rating")
        dict.updateValue(Auth.auth().currentUser?.uid ?? 0, forKey: "user")
        
        fountainRef.child(reviewId).setValue(dict)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return false
    }
    
    func centerElements() {
        reviewField.center.x = self.view.center.x
        descField.center.x = self.view.center.x
        tempSlider.center.x = self.view.center.x
        addButton.center.x = self.view.center.x
        bottleSwitch.center.x = self.view.center.x * 1.5
        bottleLabel.center.x = self.view.center.x * 1.5
        serviceSwitch.center.x = self.view.center.x * 0.5
        serviceLabel.center.x = self.view.center.x * 0.5
        ratingControl.center.x = self.view.center.x
        
    }
}