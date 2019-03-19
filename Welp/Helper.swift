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
    
    static func uploadProfPicToFirebase(image: URL, key: String) {
        let storageRef = Storage.storage().reference()
        let dbRef = Database.database().reference()
        var imageUrl = ""
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child("profilePics/\(key).jpg")
        let userRef = dbRef.child("/users/\(key)/profilePic")
        
        
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
    
    static func tempDescription(temp: Double) -> String{
        if temp >= 81 {
            return "Welpers say the water here is usually burning hot!"
        } else if temp >= 61 {
            return "Welpers say the water here is usually warm"
        } else if temp >= 41 {
            return "Welpers say the water here is usually room temperature"
        } else if temp >= 21 {
            return "Welpers say the water here is usually cool"
        } else {
            return "Welpers say the water here is usually ice cold"
        }
    }
    
    static func uploadReviewImgToFirebase(image: URL, key: String) {
        let storageRef = Storage.storage().reference()
        let dbRef = Database.database().reference()
        var imageUrl = ""
        
        // Create a reference to the file you want to upload
        print(key.last!)
        print(key.dropLast())
        let imageRef = storageRef.child("reviewPics/\(key).jpg")
        let reviewRef = dbRef.child("/reviews/\(key.dropLast())/images")
        
        
        _ = imageRef.putFile(from: image, metadata: nil) { metadata, error in
            guard metadata != nil else {
                return
            }
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                
                imageUrl = downloadURL.absoluteString
                reviewRef.child("\(key.last!)").setValue(imageUrl)
            }
        }
        
    }
}
