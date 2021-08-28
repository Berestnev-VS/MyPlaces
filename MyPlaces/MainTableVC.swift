
import UIKit

class MainTableVC: UITableViewController {
    
    var places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: tableView, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)  //отвечает за скрытие клавиатуры при нажатии по экрану
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! CustomCell
        
        let placeOnRow = places[indexPath.row]
        
        cell.nameLabel?.text = placeOnRow.name
        cell.locationLabel.text = placeOnRow.location
        cell.emojiCategory.text = placeOnRow.category
        
        if placeOnRow.image == nil {
            cell.imagePlace?.image = UIImage(named: placeOnRow.restaurantImage!) //убрать unwrap
        } else {
            cell.imagePlace.image = placeOnRow.image
        }
        
        cell.imagePlace?.layer.cornerRadius = 20
        cell.imagePlace.clipsToBounds = true
        return cell
    }
    
    @IBAction func segueSaveButton(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? AddNewCellTVC else { return }
        newPlaceVC.saveNewPlace()
        places.append(newPlaceVC.newPlace!)
        tableView.reloadData()
    }
    
}
