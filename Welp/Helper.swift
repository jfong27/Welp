//
//  Helper.swift
//  Welp
//
//  Created by Jason Fong on 2/14/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices
import AVFoundation
import FirebaseStorage
import FirebaseDatabase

class Helper {
    
    var player: AVAudioPlayer?
    
    static func addShadowToButton(button: UIButton) -> UIButton {
        
       
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 3
        button.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        return button
    }
    
    static func vibrate() {
        let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(vibrate)
    }
    
    static func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    static func uploadImageToFirebase(image: URL, imageFolder: String, uid: String) {
        let storageRef = Storage.storage().reference()
        let dbRef = Database.database().reference()
        var imageUrl = ""
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child("\(imageFolder)/\(uid).jpg")
        let userRef = dbRef.child("/users/\(uid)/profilePic")
        
        
        // Upload the file to the path "images/rivers.jpg"
        _ = imageRef.putFile(from: image, metadata: nil) { metadata, error in
            guard metadata != nil else {
                return
            }

            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                imageUrl = downloadURL.absoluteString
                userRef.setValue(imageUrl)
            }
        }
        
    }
    
}
