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

class AddReviewVC : UIViewController, UITextViewDelegate,
                    UINavigationControllerDelegate,
                    UIImagePickerControllerDelegate {
    
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var serviceSwitch: UISwitch!
    @IBOutlet weak var fillerSwitch: UISwitch!
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var thumbOne: UIImageView!
    @IBOutlet weak var thumbTwo: UIImageView!
    @IBOutlet weak var thumbThree: UIImageView!
    @IBOutlet weak var addPictureBtn: UIButton!
    
    var passedFountain : WaterFountain?
    var dbRef: DatabaseReference!
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    let reviewId = Helper.randomAlphaNumericString(length: 10)
    let placeholderText = "Ex: This water fountain is awesome! It's always very clean" +
                          " and has crisp cool water every time! The water bottle " +
                          "filler is another added bonus. Highly recommend!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        self.hideKeyboard()
        imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        setupElements()
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addReview(_ sender: Any) {
        
        let fountainId = passedFountain?.fountainId ?? ""
        let uid = Auth.auth().currentUser?.uid ?? ""

        updateFountainInFirebase(fountainId: fountainId, reviewId: reviewId)
        addReviewToFirebase(fountainId: fountainId, reviewId: reviewId, uid: uid)
        linkReviewToUser(reviewId: reviewId, uid: uid)
        
        self.performSegue(withIdentifier: "ReviewFinishedSegue", sender: self)
    }
    
    private func updateFountainInFirebase(fountainId: String, reviewId: String) {
        let fountainRef = self.dbRef.child("fountains")
    
        var ratingTotal = 0.0
        var tempTotal = 0.0
        var numReviews = 0.0
        
        print("FOUNTAIN")
        print(fountainId)
        
        dbRef.child("reviews").queryOrdered(byChild: "fountain").queryEqual(toValue: fountainId).observeSingleEvent(of: .value, with: { snapshot in
            
            let fetchedList = snapshot.children.allObjects as? [DataSnapshot]
            for snap in fetchedList! {
                let snapDict = snap.value as! [String: AnyObject]
                ratingTotal = ratingTotal + Double((snapDict["rating"] as! Int))
                tempTotal = tempTotal + Double((snapDict["temperature"] as! Double))
                numReviews = numReviews + 1
            }
            
            let newAvgRating = Double(ratingTotal)/Double(numReviews)
            let newAvgTemp = Double(tempTotal)/Double(numReviews)
            fountainRef.child(fountainId).child("avgRating").setValue(newAvgRating)
            fountainRef.child(fountainId).child("avgTemp").setValue(newAvgTemp)
        })
        
        fountainRef.child(fountainId).child("inService").setValue(serviceSwitch.isOn)
        fountainRef.child(fountainId).child("reviews").child(reviewId).setValue(true)

    }
    
    private func addReviewToFirebase(fountainId: String, reviewId: String, uid: String) {
        var dict = [String:Any]()
        let reviewRef = self.dbRef.child("reviews")
        
        print("REVIEW")
        //Randomly generated string fountainId is the primary key
        
        dict.updateValue(fountainId, forKey: "fountain")
        dict.updateValue(reviewField.text, forKey: "review")
        dict.updateValue(serviceSwitch.isOn, forKey: "inService")
        dict.updateValue(fillerSwitch.isOn, forKey: "hasBottleFiller")
        dict.updateValue(tempSlider.value, forKey: "temperature")
        dict.updateValue(ratingControl.rating, forKey: "rating")
        dict.updateValue(uid, forKey: "user")
        
        
        
        reviewRef.child(reviewId).setValue(dict)
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
        thumbOne.clipsToBounds = true
        thumbOne.layer.cornerRadius = thumbOne.frame.size.height/2
        thumbOne.contentMode = .scaleAspectFill
        thumbOne.isHidden = true
        thumbTwo.clipsToBounds = true
        thumbTwo.layer.cornerRadius = thumbTwo.frame.size.height/2
        thumbTwo.contentMode = .scaleAspectFill
        thumbTwo.isHidden = true
        thumbThree.clipsToBounds = true
        thumbThree.layer.cornerRadius = thumbThree.frame.size.height/2
        thumbThree.contentMode = .scaleAspectFill
        thumbThree.isHidden = true
    }
 
    @IBAction func addPictureBtnAction(sender: UIButton) {
        addPictureBtn.isEnabled = false
        
        let alertController : UIAlertController = UIAlertController(title: "Add Photo to Review", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
        let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
            print("camera Selected...")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
                
                self.imagePicker.sourceType = .camera
                self.present()
                
            } else {
                self.present(self.showAlert(Title: "Title", Message: "Camera is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
                self.addPictureBtn.isEnabled = true
                
            }
            
        })
        
        let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(libraryAction) in
            
            print("Photo library selected....")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                
                self.imagePicker.sourceType = .photoLibrary
                self.present()
                
            } else {
                
                self.present(self.showAlert(Title: "Title", Message: "Photo Library is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
            }
        })
        
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
            print("Cancel action was pressed")
        })
        
        alertController.addAction(cameraAction)
        
        alertController.addAction(libraryAction)
        
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func present(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageUrl: URL
        
        if let possibleImage = info[.imageURL] as? URL {
            imageUrl = possibleImage
        } else {
            return
        }

        var key = reviewId
        if thumbOne.isHidden {
            key = key + "A"
        } else if thumbTwo.isHidden {
            key = key + "B"
        } else {
            key = key + "C"
        }

        Helper.uploadReviewImgToFirebase(image: imageUrl, key: key)
        
        addPictureBtn.isEnabled = true
        
        updateThumbnail(image: info[.originalImage] as! UIImage)
        
        dismiss(animated: true)
    }
    
    private func updateThumbnail(image : UIImage) {
        if thumbOne.isHidden {
            thumbOne.image = image
            thumbOne.isHidden = false
        } else if thumbTwo.isHidden {
            thumbTwo.image = image
            thumbTwo.isHidden = false
        } else if thumbThree.isHidden {
            thumbThree.image = image
            thumbThree.isHidden = false
            addPictureBtn.isEnabled = false
        }
    }
    
    func showAlert(Title : String!, Message : String!) -> UIAlertController {
        
        let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
            print("User pressed ok function")
            
        }
        
        alertController.addAction(okAction)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        return alertController
    }
}
