//
//  CreateProfile.swift
//  Welp
//
//  Created by Jason Fong on 3/2/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class CreateProfileVC : UIViewController {
    
    var emailPassed : String?
    var pwdPassed : String?
    var dbRef : DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dbRef = Database.database().reference()
        
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func signup() {
        if let email = emailPassed, let pwd = pwdPassed {
            Auth.auth().createUser(withEmail: email, password: pwd) { (authResult, error) in
                if let error = error {
                    
                    let alert = UIAlertController(title: "Uh oh", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Got it!", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.addToDatabase(user: Auth.auth().currentUser!)
                
                }
            }
        }
    }
    
    private func addToDatabase(user: User) {
        var dict = [String:Any]()
        
        
        dict.updateValue(user.uid, forKey: "uid")
        dict.updateValue(user.email!, forKey: "email")
        
        dbRef.child("users")
            .child(Auth.auth().currentUser!.uid)
            .setValue(dict)
    }
    
}
