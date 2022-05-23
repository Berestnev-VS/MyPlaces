import RealmSwift
import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchControllerMain = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    var mainPreviewImage: UIImage?
     
    private var searchBarIsEmpty: Bool {
        guard let text = searchControllerMain.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isSearching: Bool {
        return searchControllerMain.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeSegmentedControl.apportionsSegmentWidthsByContent = true
        typeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
        places = realm.objects(Place.self)
        
        //Настройка searchController
        searchControllerMain.searchResultsUpdater = self
        searchControllerMain.obscuresBackgroundDuringPresentation = false
        searchControllerMain.searchBar.placeholder = "Search"
        navigationItem.searchController = searchControllerMain
        searchControllerMain.definesPresentationContext = true
        searchControllerMain.isActive = false
        
        if searchControllerMain.isActive {
            self.typeSegmentedControl.layer.isHidden = true
        }
    }

    // MARK: - TableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredPlaces.count
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! CustomCell
        let placeOnRow = isSearching ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel?.text = placeOnRow.name
        cell.locationLabel.text = placeOnRow.location
        cell.emojiCategory.text = placeOnRow.category
        cell.imagePlace.image = UIImage(data: placeOnRow.imageData!)
        
        if placeOnRow.category == nil {
            cell.backgroundImageCategory.isHidden = true
        } else if placeOnRow.category == "" {
            cell.backgroundImageCategory.isHidden = true
        } else {
            cell.backgroundImageCategory.isHidden = false
        }
    
        if placeOnRow.rating == 0 {
            cell.ratingForCell.isHidden = true
            cell.backgroundForRating.isHidden = true
        } else {
            cell.ratingForCell.isHidden = false
            cell.backgroundForRating.isHidden = false
        }
        
        switch placeOnRow.rating {
        case 1:
            cell.ratingForCell.image = UIImage(named: "1|5")
        case 2:
            cell.ratingForCell.image = UIImage(named: "2|5")
        case 3:
            cell.ratingForCell.image = UIImage(named: "3|5")
        case 4:
            cell.ratingForCell.image = UIImage(named: "4|5")
        case 5:
            cell.ratingForCell.image = UIImage(named: "5|5")
        default:
            break
        }
        
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
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = mainTableView.indexPathForSelectedRow else { return }
            let place = isSearching ? filteredPlaces[indexPath.row] : places[indexPath.row]
            let selectedPlaceVC = segue.destination as! AddNewCellTVC
            selectedPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func segueSaveButton(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddNewCellTVC else { return }
        newPlaceVC.savePlace()
        mainTableView.reloadData()
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
        filteredPlaces = realm.objects(Place.self).filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR category CONTAINS[c] %@", searchText, searchText, searchText)
        mainTableView.reloadData()
    }
    
}
