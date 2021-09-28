//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владимир on 26.07.2021.
//

import RealmSwift
import UIKit

class Place: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var location: String?
    @objc dynamic var comment: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var type: String?
    @objc dynamic var category: String?
    @objc dynamic var rating = 0
    // @objc dynamic var isFavorite: Bool = false
   
    convenience init(name: String, location: String?, comment: String?, imageData: Data?, type: String?, category: String?, rating: Int) { // isFavorite: Bool
        self.init()
        self.name = name
        self.location = location
        self.comment = comment
        self.imageData = imageData
        self.type = type
        self.category = category
        self.rating = rating
        // self.isFavorite = isFavorite
    }
}
 
