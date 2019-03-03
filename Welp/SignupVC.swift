//
//  SignupVC.swift
//  Welp
//
//  Created by Jason Fong on 2/13/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit

class SignupVC: UIViewController {
    
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signupBox: UIView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signupBox.layer.cornerRadius = 6;
        signupBox.layer.masksToBounds = true;
        signupBox.layer.shadowOpacity = 10.0
        signupBox.center = self.view.center
        
        signupButton.alpha = 0.8
        signupButton.layer.cornerRadius = 15.0
        
        signupLabel.center.x = self.view.center.x
        signupLabel.center.y = self.view.center.y/2
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateProfileSegue" {
            let vc = segue.destination as! CreateProfileVC
            vc.pwdPassed = pwdField.text
            vc.emailPassed = emailField.text
        }
    }
    
    @IBAction func signupButton(_ sender: Any) {
        self.performSegue(withIdentifier: "CreateProfileSegue", sender: self)
        
    }
    
    @IBAction func exitButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
