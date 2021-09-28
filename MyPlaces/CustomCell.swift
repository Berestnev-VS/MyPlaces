//
//  CustomCell.swift
//  MyPlaces
//
//  Created by Владимир on 23.07.2021.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var imagePlace: UIImageView! {
        didSet {
            imagePlace?.layer.cornerRadius = 20
            imagePlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var backgroundImageCategory: UIImageView!
    @IBOutlet weak var emojiCategory: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var backgroundForRating: UIImageView!
    @IBOutlet weak var ratingForCell: UIImageView!
}

