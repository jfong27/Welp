//
//  RootProfileVC.swift
//  Welp
//
//  Created by Jason Fong on 3/1/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class RootProfileVC : UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async(){
                print("Logged in already")
                self.performSegue(withIdentifier: "ProfileSegue", sender: self)
            }
        } else {
            print("Not logged in")
            self.performSegue(withIdentifier: "LogInSegue", sender: self)
        }
    }
}
