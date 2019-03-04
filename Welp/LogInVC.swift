//
//  LogInVC.swift
//  Welp
//
//  Created by Jason Fong on 2/13/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit

class LogInVC: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var loginLabel: UILabel!
    
    var dbRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "RootSegue", sender: self)
        }
                
        self.dbRef = Database.database().reference()
        
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.delegate = self
        
        viewBox.layer.cornerRadius = 6;
        viewBox.layer.masksToBounds = true;
        viewBox.layer.shadowOpacity = 10.0
        
        loginButton.alpha = 0.8
        loginButton.layer.cornerRadius = 15.0
        viewBox.center = self.view.center
        
        loginLabel.center.x = self.view.center.x
        loginLabel.center.y = self.view.center.y/2
        
        emailField.keyboardType = .emailAddress
        
        self.view.addSubview(fbLoginButton)
        fbLoginButton.center = CGPoint.init(x: self.view.center.x,
                                            y: self.view.center.y*2 - 200)
        
        
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailField.text = ""
        pwdField.text = ""
        loading.isHidden = true
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailField.hasText && pwdField.hasText {
            loginButton.alpha = 1.0
        }
    }
    
    @IBAction func loginPress(_ sender: Any) {
        loading.startAnimating()
        loading.isHidden = false
        
        if let email = emailField.text, let password = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Uh oh!", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.loading.isHidden = true
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    func loginButton(_ fbButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {

        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            print(FBSDKAccessToken.current())
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential) {(authResult, error) in
                if let error = error {
                    print(error)
                } else {
                    if ((authResult?.additionalUserInfo?.isNewUser) ?? false) {
                        self.addFBUserToDB()
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    private func addFBUserToDB() {
        let user = Auth.auth().currentUser!
        var dict = [String:Any]()
        
        let firstName = user.displayName?.split(separator: " ")[0]
        let lastName = user.displayName?.split(separator: " ")[1]
        let city = "city"
        let state = "State"

        dict.updateValue(firstName, forKey: "firstName")
        dict.updateValue(lastName, forKey: "lastName")
        dict.updateValue(city, forKey: "city")
        dict.updateValue(state, forKey: "state")
        dict.updateValue(user.email!, forKey: "email")
        dict.updateValue(0, forKey: "reviews")

        dbRef.child("users")
            .child(user.uid)
            .setValue(dict)

    }
    @IBAction func signupPress(_ sender: Any) {
        self.performSegue(withIdentifier: "signupSegue", sender: sender)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            pwdField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
