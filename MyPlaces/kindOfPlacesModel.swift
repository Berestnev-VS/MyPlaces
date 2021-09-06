import Foundation

struct Category {
    var id  : Int
    var name: String
}
struct Type {
    var id  : Int
    var name: String
    var category_id: Int
}

class ModelForPicker {
    
    var categories = [Category]()
    var types = [Type]()
    var typesByCategories = [Type]()
    
    init() {
        setupData()
    }
    func setupData() {
        let category1 = Category(id: 1, name: "Рестораны и бары")
        let category2 = Category(id: 2, name: "Развлечения")
        let category3 = Category(id: 3, name: "Парки и аттракционы")
        
        categories.append(category1)
        categories.append(category2)
        categories.append(category3)
        
        let type11 = Type(id: 1, name: "🍕", category_id: 1)
        let type12 = Type(id: 2, name: "🍣", category_id: 1)
        let type13 = Type(id: 3, name: "🍔", category_id: 1)
        let type14 = Type(id: 4, name: "🥗", category_id: 1)
        let type15 = Type(id: 5, name: "🍝", category_id: 1)
        let type16 = Type(id: 6, name: "🍤", category_id: 1)
        let type17 = Type(id: 7, name: "🍨", category_id: 1)
        let type18 = Type(id: 8, name: "🍩", category_id: 1)
        let type19 = Type(id: 9, name: "🐟", category_id: 1)
        
        types.append(type11)
        types.append(type12)
        types.append(type13)
        types.append(type14)
        types.append(type15)
        types.append(type16)
        types.append(type17)
        types.append(type18)
        types.append(type19)
        
        let type21 = Type(id: 7, name: "🎬", category_id: 2)
        let type22 = Type(id: 8, name: "🎳", category_id: 2)
        let type23 = Type(id: 9, name: "🎪", category_id: 2)
        
        types.append(type21)
        types.append(type22)
        types.append(type23)
        
        let type31 = Type(id: 10, name: "🌳", category_id: 3)
        let type32 = Type(id: 11, name: "🎢", category_id: 3)
        types.append(type31)
        types.append(type32)
        
        self.typesByCategories = getTypes(category_id: categories.first!.id)
    }
    
    func getTypes(category_id: Int) -> [Type] {
        
        let types = self.types.filter { (matchesType) -> Bool in
            matchesType.category_id == category_id
        }
        return types
     }
}
