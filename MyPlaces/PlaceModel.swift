//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владимир on 26.07.2021.
//

import RealmSwift
import UIKit

class Place: Object {
    var name = ""
    @objc dynamic var location: String?
    @objc dynamic var category: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var comment: String?
    
    let restaurantNames: [String] = ["KFC","McDonalds",
                                     "Burger Heroes","Якитория",
                                     "Тануки","Рыба моя",
                                     "ЙУХ","Хачапури  и Вино"]
    
    func savePlaces() {
        for place in restaurantNames {
            
            let image = UIImage(named: place)
            guard let imageData = image?.pngData() else { return }
            
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.category = "🍩"
            newPlace.location = "Москва"
            newPlace.comment = "Кеквейт!"
            newPlace.imageData = imageData
            
            StorageManager.saveObjects(newPlace)
        }
    }
}
