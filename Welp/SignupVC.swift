//
//  SignupVC.swift
//  Welp
//
//  Created by Jason Fong on 2/13/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignupVC: UIViewController {
    
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signupBox: UIView!
    @IBOutlet weak var signupButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupBox.layer.cornerRadius = 6;
        signupBox.layer.masksToBounds = true;
        signupBox.layer.shadowOpacity = 10.0

        signupButton.alpha = 0.8
        
        emailField.keyboardType = .emailAddress
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if emailField.hasText && pwdField.hasText {
            signupButton.alpha = 1.0
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
    
    @IBAction func signupButton(_ sender: Any) {
        
        if let email = emailField.text, let pwd = pwdField.text {
            Auth.auth().createUser(withEmail: email, password: pwd) { (authResult, error) in
                if let error = error {
                
                    let alert = UIAlertController(title: "Uh oh", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Got it!", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "doneSignupSegue", sender: sender)
                }
            }
        }
    }
    
    
}
