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
    
    @IBOutlet weak var nameLabel: UILabel!
    var handle : AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile loaded")
        nameLabel.text = Auth.auth().currentUser?.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func logOut(_ sender: Any) {
        try! Auth.auth().signOut()
        
        _ = navigationController?.popToRootViewController(animated: true)
    }
}
