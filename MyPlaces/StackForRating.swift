//
//  StackForRating.swift
//  MyPlaces
//
//  Created by Владимир on 09.09.2021.
//

import UIKit

class StackForRating: UIStackView {

    // MARK: Properties
    
    var rating: Int = 0
    
    private var buttonStackArray = [UIButton]()
    
    private var buttonSize: CGSize = CGSize(width: 35.0, height: 35.0)
    
    private var buttonCount: Int = 5
    
    // MARK:  Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button action
    
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed")
    }

    private func setupButtons() {
        
        for _ in 1...buttonCount {
            // Create button
            let button = UIButton()
            button.backgroundColor = .none
            button.setTitle("☆", for: .normal)
            button.setTitleColor(.black, for: .normal)
            //
            //Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant:  buttonSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize.width).isActive = true
            
            //Setup button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            //Add the button to stack
            addArrangedSubview(button)
        
            // Add the new button to array
            buttonStackArray.append(button)
        }
    }
}
