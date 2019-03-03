//
//  RatingControl.swift
//  Welp
//
//  Created by Jason Fong on 3/2/19.
//  Copyright © 2019 Jason Fong. All rights reserved.
//

import UIKit

@IBDesignable
class RatingControl: UIStackView {
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var ratingSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    @IBInspectable var ratingCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let blueDrop = UIImage(named: "blueDrop", in: bundle, compatibleWith: self.traitCollection)
        let emptyDrop = UIImage(named:"emptyDrop", in: bundle, compatibleWith: self.traitCollection)
        let shinyDrop = UIImage(named:"shinyDrop", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<ratingCount {
            // Create the button
            let button = UIButton()
            button.setImage(emptyDrop, for: .normal)
            button.setImage(shinyDrop, for: .selected)
            button.setImage(blueDrop, for: .highlighted)
            button.setImage(blueDrop, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: ratingSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: ratingSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
    }
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            // If the selected star represents the current rating, reset the rating to 0.
            rating = 0
        } else {
            // Otherwise set the rating to the selected star
            rating = selectedRating
        }
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
        }
    }
    
}
