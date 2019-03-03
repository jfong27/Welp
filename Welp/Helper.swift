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
    
    static func playSoundAndVibrate() {
//        DispatchQueue.global().async {
//            SystenmSoundId(kSystemSoundID)
//            let systemSoundID: SystemSoundID = 1309
//
//            let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
//
//            // to play sound
//            AudioServicesPlaySystemSound (systemSoundID)
//            AudioServicesPlaySystemSound(vibrate)
//        }
        
        
    }
    static func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}
