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


class ProfileVC : UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    
    var signInMethodIsFB = false
    var handle : AuthStateDidChangeListenerHandle?
    var dbRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        self.dbRef = Database.database().reference()
        profPic.contentMode = .scaleToFill
        arrangeElements()
        
        fetchUserData(user: user!)
        
        let providerData = user?.providerData
        for userInfo in providerData! {
            if (userInfo.providerID == "facebook.com") {
                setupFBButton()
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
            let numReviews = value?["reviews"] as? Int ?? 0

            self.numReviewsLabel.text = String(numReviews) + " Reviews"
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func setupFBButton() {
        let logoutButton = FBSDKLoginButton()
        logoutButton.delegate = self
        
        logoutButton.alpha = 0.8
        logoutButton.layer.cornerRadius = 15.0
        
        self.view.addSubview(logoutButton)
        logoutButton.center = CGPoint.init(x: self.view.center.x,
                                          y: self.view.center.y + 300)
        
    }
    
    private func setupDefaultButton() {
        let logoutButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 20))
        
        logoutButton.backgroundColor = .green
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.center.x = self.view.center.x
        logoutButton.center.y = self.view.center.y + 300
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
            print(userId)
            let link = "https://graph.facebook.com/\(userId)/picture?type=large"
            print(link)
            DispatchQueue.global(qos: .userInitiated).async {
                let url = URL(string: link)
                let responseData = try? Data(contentsOf: url!)
                let downloadedImage = UIImage(data: responseData!)
                
                DispatchQueue.main.async {
                    self.profPic.image = downloadedImage
                    self.profPic.layer.masksToBounds = false
                    self.profPic.layer.borderColor = UIColor.black.cgColor
                    self.profPic.layer.cornerRadius = self.profPic.frame.height/2
                    self.profPic.clipsToBounds = true
                }
            }
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
    }
}

