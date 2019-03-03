//
//  ProfileVC.swift
//  Welp
//
//  Created by Jason Fong on 2/6/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit


class ProfileVC : UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numReviewsLabel: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    
    var handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = Auth.auth().currentUser?.displayName
        homeLabel.text = Auth.auth().currentUser?.uid
        
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        
        loginButton.alpha = 0.8
        loginButton.layer.cornerRadius = 15.0
        
        self.view.addSubview(loginButton)
        loginButton.center = CGPoint.init(x: self.view.center.x,
                                          y: self.view.center.y + 300)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        print(Auth.auth())
//        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func logOut(_ sender: Any) {
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
    
}

