//
//  HideKeyboard.swift
//  Welp
//
//  Created by Jason Fong on 3/2/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//
import UIKit
import Foundation

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
