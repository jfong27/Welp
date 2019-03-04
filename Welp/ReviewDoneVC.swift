//
//  ReviewDoneVC.swift
//  Welp
//
//  Created by Jason Fong on 3/2/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ReviewDoneVC : UIViewController {
    
    @IBOutlet weak var thankyouLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thankyouLabel.center.x = self.view.center.x
        thankyouLabel.center.y = self.view.center.y/1.5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.75) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    var player : AVAudioPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    
}
