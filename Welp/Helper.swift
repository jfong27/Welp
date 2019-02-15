//
//  Helper.swift
//  Welp
//
//  Created by Jason Fong on 2/14/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

class Helper {
    
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
}
