//
//  UIVCExt.swift
//  Welp
//
//  Created by Jason Fong on 3/4/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        print("DOWNLOADING LINK")
        print(link)
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    func makeCircle() {
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.layer.cornerRadius = self.frame.size.height/2
    }
    
}
