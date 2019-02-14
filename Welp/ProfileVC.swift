//
//  ProfileVC.swift
//  Welp
//
//  Created by Jason Fong on 2/6/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC : UIViewController {
    
    var handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}
