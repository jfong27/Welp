//
//  AddReviewVC.swift
//  Welp
//
//  Created by Jason Fong on 3/3/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AddReviewVC : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var serviceSwitch: UISwitch!
    @IBOutlet weak var fillerSwitch: UISwitch!
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var ratingControl: RatingControl!
    
    var passedFountain : WaterFountain?
    var dbRef: DatabaseReference!
    
    let placeholderText = "Ex: This water fountain is awesome! It's always very clean" +
                          " and has crisp cool water every time! The water bottle " +
                          "filler is another added bonus. Highly recommend!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        
        setupElements()
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addReview(_ sender: Any) {
        
        let fountainId = passedFountain?.fountainId ?? ""
        let reviewId = Helper.randomAlphaNumericString(length: 10)
        let uid = Auth.auth().currentUser?.uid ?? ""

        updateFountainInFirebase(fountainId: fountainId, reviewId: reviewId)
        addReviewToFirebase(fountainId: fountainId, reviewId: reviewId, uid: uid)
        linkReviewToUser(reviewId: reviewId, uid: uid)
        
        self.performSegue(withIdentifier: "ReviewFinishedSegue", sender: self)
    }
    
    private func updateFountainInFirebase(fountainId: String, reviewId: String) {
        let fountainRef = self.dbRef.child("fountains")
        
        var total = Double(ratingControl.rating)
        var numReviews = 1.0
        
        dbRef.child("reviews").queryOrdered(byChild: "fountain").queryEqual(toValue: fountainId).observeSingleEvent(of: .value, with: { snapshot in
            
            let fetchedList = snapshot.children.allObjects as? [DataSnapshot]
            for snap in fetchedList! {
                let snapDict = snap.value as! [String: AnyObject]
                print("OK")
                print(snapDict["rating"]!)
                print("UH HUH")
                
                total = total + Double((snapDict["rating"] as! Int))
                numReviews = numReviews + 1
            }
            let newAvgRating = total/numReviews
            fountainRef.child(fountainId).child("avgRating").setValue(newAvgRating)
        })
        
        fountainRef.child(fountainId).child("inService").setValue(serviceSwitch.isOn)
        fountainRef.child(fountainId).child("reviews").child(reviewId).setValue(true)

    }
    
    private func addReviewToFirebase(fountainId: String, reviewId: String, uid: String) {
        var dict = [String:Any]()
        let fountainRef = self.dbRef.child("reviews")
        
        //Randomly generated string fountainId is the primary key
        
        dict.updateValue(fountainId, forKey: "fountain")
        dict.updateValue(reviewField.text, forKey: "review")
        dict.updateValue(serviceSwitch.isOn, forKey: "inService")
        dict.updateValue(fillerSwitch.isOn, forKey: "hasBottleFiller")
        dict.updateValue(tempSlider.value, forKey: "temperature")
        dict.updateValue(ratingControl.rating, forKey: "rating")
        dict.updateValue(uid, forKey: "user")
        
        fountainRef.child(reviewId).setValue(dict)
    }
    
    private func linkReviewToUser(reviewId: String, uid: String) {
        
        dbRef.child("users/\(uid)/reviews").observeSingleEvent(of: .value, with: { snapshot in
            let initialValue = snapshot.value
            let value = (initialValue as! Int) + 1
            self.dbRef.child("users/\(uid)/reviews").setValue(value)
        })
        
        dbRef.child("users/\(uid)/reviewIds/\(reviewId)").setValue(true)
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return false
    }
    
    private func setupElements() {
        addReviewButton.layer.cornerRadius = 15.0
        reviewField.delegate = self
        reviewField.text = placeholderText
        reviewField.textColor = .lightGray
        tempSlider.maximumTrackTintColor = .blue
    }
    
}
