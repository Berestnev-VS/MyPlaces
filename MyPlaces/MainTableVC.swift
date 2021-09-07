import RealmSwift
import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeSegmentedControl.apportionsSegmentWidthsByContent = true // TODO: вынести в отдельную функцию
        typeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
        places = realm.objects(Place.self)
    }

    // MARK: - TableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! CustomCell

        let placeOnRow = places[indexPath.row]

        cell.nameLabel?.text = placeOnRow.name
        cell.locationLabel.text = placeOnRow.location
        cell.emojiCategory.text = placeOnRow.category
        cell.imagePlace.image = UIImage(data: placeOnRow.imageData!)
        
        cell.imagePlace?.layer.cornerRadius = 20
        cell.imagePlace.clipsToBounds = true
    
        return cell
    }
    
    // MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = deletePlaceAction(at: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
    
    private func deletePlaceAction(at indexPath: IndexPath) -> UIContextualAction {
        let place = places[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            StorageManager.deleteObjects(place)
            self.mainTableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        return action
    }
//    private func favoriteAction(at indexPath: IndexPath) -> UIContextualAction {
//        let place = places[indexPath.row]
//        let action = UIContextualAction(style: .normal, title: "Love it") { action, view, completion in
//            place.isFavorite = !place.isFavorite
//            try! realm.write {
//                self.places[indexPath.row] = place
//                place.isFavorite = !place.isFavorite
//            }
//            completion(true)
//        }
//        action.backgroundColor = place.isFavorite ? .systemPink : .systemGray
//        action.image = place.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
//        return action
//    } TODO: в будущем добавить избранные заведения
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   // TODO: реализовать перемещение ячеек
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = mainTableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let selectedPlaceVC = segue.destination as! AddNewCellTVC
            selectedPlaceVC.currentPlace = place 
        }
    }
    
    @IBAction func segueSaveButton(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddNewCellTVC else { return }
        newPlaceVC.savePlace()
        mainTableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        let realm = try! Realm()

        switch sender.selectedSegmentIndex {
        case 0:
            let result = realm.objects(Place.self).filter("ANY type.text = 'Рестораны'")
            print(result)
        case 1:
            let result = realm.objects(Place.self).filter("ANY type.text = 'Развлечения'")
            print(result)
        case 2:
            let result = realm.objects(Place.self).filter("ANY type.text = 'Парки'")
            print(result)
        default:
            print("kek")
        }
    }
    
}
// TODO: сделать кнопку прокладывания маршрута по свайпу в лево
