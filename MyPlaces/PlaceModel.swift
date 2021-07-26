//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Владимир on 26.07.2021.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let restaurantNames: [String] = ["KFC","McDonalds",
                                     "Burger Heroes","Якитория",
                                     "Тануки","Рыба моя",
                                     "ЙУХ","Хачапури и Вино"]
    
    static func getPlaces () -> [Place] {
        var places = [Place]()
        for place in restaurantNames {
            places.append(Place(name: place, location: "Москва", type: "Роллы", image: place))
        }
        return places
    }
}
