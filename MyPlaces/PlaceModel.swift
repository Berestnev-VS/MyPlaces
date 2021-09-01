//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владимир on 26.07.2021.
//

import RealmSwift
import UIKit

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var category: String?
    @objc dynamic var comment: String?
    @objc dynamic var imageData: Data?
   
    convenience init(name: String, location: String?, category: String?, comment: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.category = category
        self.comment = comment
        self.imageData = imageData
    }
}
 
