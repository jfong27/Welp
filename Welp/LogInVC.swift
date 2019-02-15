//
//  LogInVC.swift
//  Welp
//
//  Created by Jason Fong on 2/13/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit

class LogInVC: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
 
    
    
    
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewBox.layer.cornerRadius = 6;
        viewBox.layer.masksToBounds = true;
        viewBox.layer.shadowOpacity = 10.0
        
        loginButton.alpha = 0.8
        loginButton.layer.cornerRadius = 15.0
        
        emailField.keyboardType = .emailAddress
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailField.hasText && pwdField.hasText {
            loginButton.alpha = 1.0
        }
    }
    
    @IBAction func loginPress(_ sender: Any) {
        if let email = emailField.text, let password = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Uh oh!", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: sender)
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
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential) {(authResult, error) in
                if let error = error {
                    print(error)
                } else {
                    print("Signed in with fb")
                }
            }
        }
    }
    
    
    @IBAction func signupPress(_ sender: Any) {
        self.performSegue(withIdentifier: "signupSegue", sender: sender)
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.getFBUserData()
            }
        }
    }
    
    func getFBUserData() {
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, picture.type(large), email"]).start(completionHandler: {(connection, result, error) -> Void in
                
                if let error = error {
                    print(error)
                } else {
                    print(result!)
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            pwdField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func googleButton(_ sender: Any) {
    }
    
    @IBAction func twitterButton(_ sender: Any) {
    }
    
}
