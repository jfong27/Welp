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
import AVFoundation

class CreateProfileVC : UIViewController {
    
    var emailPassed : String?
    var pwdPassed : String?
    var dbRef : DatabaseReference!
    var player : AVAudioPlayer?
    
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var hometownField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dbRef = Database.database().reference()
        
        self.hideKeyboard()
        arrangeElements()
    }
    
    
    @IBAction func exitButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    private func addToDatabase(user: User) {
        var dict = [String:Any]()
        let firstName = firstNameField.text ?? "First Name"
        let lastName = lastNameField.text ?? "Last Name"
        let city = hometownField.text ?? "City"
        let state = stateField.text ?? "State"
        
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
    
    @IBAction func finishedButton(_ sender: Any) {
        if ((firstNameField.text?.isEmpty)! ||
            (lastNameField.text?.isEmpty)! ||
            (hometownField.text?.isEmpty)! ||
            (stateField.text?.isEmpty)!) {
            
            let alert = UIAlertController(title: "Uh oh", message: "Every field must be filled out", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Got it!", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let user = Auth.auth().currentUser!
            addToDatabase(user: user)
        
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = "\(firstNameField.text!) \(lastNameField.text!)"
            changeRequest.commitChanges { error in
                if let error = error {
                    print(error)
                } else {
                    // Profile updated.
                }
            }
            playSound()
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "tone", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            hometownField.becomeFirstResponder()
        } else if textField == hometownField {
            stateField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    private func arrangeElements() {
        fieldsView.center = self.view.center
        welcomeLabel.center.x = self.view.center.x
        welcomeLabel.center.y = self.view.center.y/3
    }
    
}
