//
//  ProfileVC.swift
//  Welp
//
//  Created by Jason Fong on 2/6/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit


class ProfileVC : UIViewController, FBSDKLoginButtonDelegate,
                  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var addPictureBtn: UIButton!
    
    var signInMethodIsFB = false
    var handle : AuthStateDidChangeListenerHandle?
    var dbRef: DatabaseReference!
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        self.dbRef = Database.database().reference()
        imagePicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        arrangeElements()
        
        fetchUserData(user: user!)
        
        let providerData = user?.providerData
        for userInfo in providerData! {
            if (userInfo.providerID == "facebook.com") {
                setupFBButton()
                addPictureBtn.isHidden = true
                signInMethodIsFB = true
            }
        }
        if !signInMethodIsFB {
            setupDefaultButton()
        }
        
        nameLabel.text = user?.displayName
        
    }
    
    private func fetchUserData(user: User) {
        
        let userID = user.uid
        dbRef.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let hometown = value?["city"] as? String ?? ""
            let state = value?["state"] as? String ?? ""
            if let picUrl = value?["profilePic"] as? String {
                self.profPic.downloaded(from: picUrl)
            }
            self.homeLabel.text = hometown + ", " + state
        }) { (error) in
            print(error.localizedDescription)
        }
        
        dbRef.child("reviews").queryOrdered(byChild: "user").queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { snapshot in
            var numReviews = 0
            let fetchedList = snapshot.children.allObjects
            numReviews = fetchedList.count + 1
            
            if numReviews == 1 {
                self.numReviewsLabel.text = String(numReviews) + " Review"
            } else {
                self.numReviewsLabel.text = String(numReviews) + " Reviews"
            }
        })
        
    }
    
    private func setupFBButton() {
        let logoutButton = FBSDKLoginButton()
        logoutButton.delegate = self
        
        logoutButton.alpha = 0.8
        logoutButton.layer.cornerRadius = 15.0
        
        self.view.addSubview(logoutButton)
        logoutButton.center = CGPoint.init(x: self.view.center.x,
                                          y: self.view.center.y * 1.65)
        
    }
    
    private func setupDefaultButton() {
        let logoutButton = UIButton(frame: CGRect(x: 100, y: 100, width: 180, height: 35))
        
        logoutButton.backgroundColor = UIColor(red:0.12, green:0.71, blue:0.42, alpha:1.0)
        logoutButton.layer.cornerRadius = 6
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.center.x = self.view.center.x
        logoutButton.center.y = self.view.center.y * 1.65
        logoutButton.addTarget(self, action: #selector(self.logOut(sender:)), for: .touchUpInside)
        
        self.view.addSubview(logoutButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserData(user: Auth.auth().currentUser!)
        if FBSDKAccessToken.current() == nil {
            return
        }
        if let userId = FBSDKAccessToken.current().userID {
            let link = "https://graph.facebook.com/\(userId)/picture?type=large"
            profPic.downloaded(from: link)
//            DispatchQueue.global(qos: .userInitiated).async {
//                let url = URL(string: link)
//                let responseData = try? Data(contentsOf: url!)
//                let downloadedImage = UIImage(data: responseData!)
//                
//                DispatchQueue.main.async {
//                    self.profPic.image = downloadedImage
//                    self.profPic.layer.masksToBounds = false
//                    self.profPic.contentMode = .scaleAspectFit
//                    self.profPic.layer.borderColor = UIColor.black.cgColor
//                    self.profPic.layer.cornerRadius = self.profPic.frame.height/3
//                    self.profPic.clipsToBounds = true
//                }
//            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @objc func logOut(sender: UIButton) {
        try! Auth.auth().signOut()
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("FB Login")
        return
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("FB Logout")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        navigationController?.popToRootViewController(animated: true)

    }
 
    private func arrangeElements() {
        nameLabel.adjustsFontSizeToFitWidth = true
        homeLabel.adjustsFontSizeToFitWidth = true
        numReviewsLabel.adjustsFontSizeToFitWidth = true
        profPic.contentMode = .scaleAspectFit
    }
    
    
    
    
    
    @IBAction func addPictureBtnAction(sender: UIButton) {
        
        addPictureBtn.isEnabled = false
        
        let alertController : UIAlertController = UIAlertController(title: "Title", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
        let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
            print("camera Selected...")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
                
                self.imagePicker.sourceType = .camera
                self.present()
                
            }else{
                self.present(self.showAlert(Title: "Title", Message: "Camera is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
                
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
            print("IMAGE URL")
            print(possibleImage.absoluteString)
            imageUrl = possibleImage
        } else {
            return
        }
        
        let user = Auth.auth().currentUser
        let uid = user?.uid ?? ""
        Helper.uploadImageToFirebase(image: imageUrl, imageFolder: "profilePics", uid: uid)
        fetchUserData(user: user!)
        
        dismiss(animated: true)
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


