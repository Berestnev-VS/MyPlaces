import RealmSwift
import UIKit

class MainTableVC: UITableViewController {
    
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        let tap = UITapGestureRecognizer(target: tableView, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)  //отвечает за скрытие клавиатуры при нажатии по экрану
    }

    // MARK: - TableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = deletePlaceAction(at: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
        swipe.performsFirstActionWithFullSwipe = false
        return swipe
    }
    
    private func deletePlaceAction(at indexPath: IndexPath) -> UIContextualAction {
        let place = places[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            StorageManager.deleteObjects(place)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        
        return action
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   // TODO: реализовать перемещение ячеек
    
    @IBAction func segueSaveButton(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddNewCellTVC else { return }
        newPlaceVC.saveNewPlace()
         
        tableView.reloadData()
    }
}

// TODO: сделать кнопку прокладывания маршрута по свайпу в лево
