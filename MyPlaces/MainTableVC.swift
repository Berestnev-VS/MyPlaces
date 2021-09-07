import RealmSwift
import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchControllerMain = UISearchController(searchResultsController: nil)
    //private var filteredPlaces: Result<Place>!
    private var places: Results<Place>!
     
    private var searchBarIsEmpty: Bool {
        guard let text = searchControllerMain.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchControllerMain.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeSegmentedControl.apportionsSegmentWidthsByContent = true // TODO: вынести в отдельную функцию
        typeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
        places = realm.objects(Place.self)
        
        //Настройка searchController
        searchControllerMain.searchResultsUpdater = self
        searchControllerMain.obscuresBackgroundDuringPresentation = false
        searchControllerMain.searchBar.placeholder = "􀒓"
        navigationItem.searchController = searchControllerMain
        definesPresentationContext = true
    }

    // MARK: - TableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return 1
        } else {
            return places.isEmpty ? 0 : places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! CustomCell

        var placeOnRow = Place()
        
        if isFiltering {
           // placeOnRow = filteredPlaces[indexPath.row]
        } else {
            placeOnRow = places[indexPath.row]
        }
        
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
            let result = realm.objects(Place.self)
            places = result
        case 1:
            let result = realm.objects(Place.self).filter("type == 'Рестораны'")
            places = result
        case 2:
            let result = realm.objects(Place.self).filter("type == 'Развлечения'")
            print(result)
            places = result
        case 3:
            let result = realm.objects(Place.self).filter("type == 'Парки'")
            print(result)
            places = result
        default:
            break
        }
        mainTableView.reloadData()
    }
    
}
// TODO: сделать кнопку прокладывания маршрута по свайпу в лево

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR category CONTAINS[c] %@", searchText, searchText, searchText)
        mainTableView.reloadData()
    }
    
}
