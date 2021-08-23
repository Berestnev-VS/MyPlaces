//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владимир on 26.07.2021.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var category: String?
    var image: UIImage?
    var comment: String?
    var restaurantImage: String?
    
    static let restaurantNames: [String] = ["KFC","McDonalds",
                                     "Burger Heroes","Якитория",
                                     "Тануки","Рыба моя",
                                     "ЙУХ","Хачапури и Вино"]
    
    static func getPlaces () -> [Place] {
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place, location: "Москва", category: "Роллы", image: nil, comment: nil, restaurantImage: place))
        }
        return places
    }
}
