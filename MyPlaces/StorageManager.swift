//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Владимир on 28.08.2021.
//

import RealmSwift

let realm = try! Realm()
khj
class StorageManager {
    
    static func saveObjects(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    static func deleteObjects(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
 
