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

class NewReviewVC : UIViewController, UITextViewDelegate, UINavigationControllerDelegate,
                    UITextFieldDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var bottleSwitch: UISwitch!
    @IBOutlet weak var bottleLabel: UILabel!
    @IBOutlet weak var serviceSwitch: UISwitch!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var addPictureBtn: UIButton!
    @IBOutlet weak var thumbOne: UIImageView!
    @IBOutlet weak var thumbTwo: UIImageView!
    @IBOutlet weak var thumbThree: UIImageView!
    
    let placeholderText = "Ex: This water fountain is awesome! It's always very clean" +
                          " and has crisp cool water every time! The water bottle " +
                          "filler is another added bonus. Highly recommend!"
    
    let reviewId = Helper.randomAlphaNumericString(length: 10)
    
    var latPassed : CLLocationDegrees?
    var lonPassed : CLLocationDegrees?
    
    var dbRef: DatabaseReference!
    var geoFire : GeoFire?
    var imagePicker : UIImagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.setupElements()
        self.dbRef = Database.database().reference()
        self.geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    }
    
    //TODO: Brand new fountain reviews will also upload to Fountains database and Geofire
    // Adding review to existing fountain will only upload to Re. 
    @IBAction func addReview(_ sender: Any) {
    
        Helper.vibrate()

        let fountainId = Helper.randomAlphaNumericString(length: 10)
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        addNewFountainToFirebase(fountainId: fountainId)
        addNewReviewToFirebase(fountainId: fountainId, uid: uid)
        linkReviewToUser(uid: uid)
        
        self.performSegue(withIdentifier: "ReviewDoneSegue", sender: self)
    }
    
    private func addNewFountainToFirebase(fountainId: String) {
        var dict = [String:Any]()
        let fountainRef = self.dbRef.child("fountains")

        dict.updateValue(descField.text!, forKey: "name")
        dict.updateValue(Double(ratingControl.rating), forKey: "avgRating")
        dict.updateValue(Double(tempSlider.value), forKey: "avgTemp")
        dict.updateValue(serviceSwitch.isOn, forKey: "inService")
        dict.updateValue(bottleSwitch.isOn, forKey: "hasBottleFiller")
        dict.updateValue(latPassed!, forKey: "latitude")
        dict.updateValue(lonPassed!, forKey: "longitude")
        
        fountainRef.child(fountainId).setValue(dict)
        fountainRef.child(fountainId).child("reviews").child(reviewId).setValue(true)
        self.geoFire?.setLocation(CLLocation(latitude: latPassed ?? 0,longitude:lonPassed ?? 0), forKey: fountainId)
    }
    
    private func addNewReviewToFirebase(fountainId: String, uid: String) {
        var dict = [String:Any]()
        let reviewRef = self.dbRef.child("reviews")
        
        //Randomly generated string fountainId is the primary key
        
        dict.updateValue(fountainId, forKey: "fountain")
        dict.updateValue(reviewField.text, forKey: "review")
        dict.updateValue(serviceSwitch.isOn, forKey: "inService")
        dict.updateValue(bottleSwitch.isOn, forKey: "hasBottleFiller")
        dict.updateValue(tempSlider.value, forKey: "temperature")
        dict.updateValue(ratingControl.rating, forKey: "rating")
        dict.updateValue(uid, forKey: "user")
        
        reviewRef.child(reviewId).updateChildValues(dict)

    }
    
    private func linkReviewToUser(uid: String) {
        dbRef.child("users/\(uid)/reviewIds/\(reviewId)").setValue(true)
    }
    
    @IBAction func exitButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
    
    func setupElements() {
        reviewField.center.x = self.view.center.x
        descField.center.x = self.view.center.x
        tempSlider.center.x = self.view.center.x
        addButton.center.x = self.view.center.x
        addButton.layer.cornerRadius = 15.0
        bottleSwitch.center.x = self.view.center.x * 1.5
        bottleLabel.center.x = self.view.center.x * 1.5
        serviceSwitch.center.x = self.view.center.x * 0.5
        serviceLabel.center.x = self.view.center.x * 0.5
        ratingControl.center.x = self.view.center.x
        reviewField.delegate = self
        reviewField.text = placeholderText
        reviewField.textColor = .lightGray
        tempSlider.maximumTrackTintColor = .blue
        thumbOne.isHidden = true
        thumbTwo.isHidden = true
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
            self.addPictureBtn.isEnabled = true
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
            thumbOne.contentMode = .scaleAspectFill
            thumbOne.clipsToBounds = true
            thumbOne.image = image
            thumbOne.layer.cornerRadius = thumbOne.frame.size.height/2
            thumbOne.isHidden = false
        } else if thumbTwo.isHidden {
            thumbTwo.contentMode = .scaleAspectFill
            thumbTwo.clipsToBounds = true
            thumbTwo.image = image
            thumbTwo.layer.cornerRadius = thumbTwo.frame.size.height/2
            thumbTwo.isHidden = false

        } else if thumbThree.isHidden {
            thumbThree.contentMode = .scaleAspectFill
            thumbThree.clipsToBounds = true
            thumbThree.image = image
            thumbThree.isHidden = false
            thumbThree.layer.cornerRadius = thumbThree.frame.size.height/2
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
