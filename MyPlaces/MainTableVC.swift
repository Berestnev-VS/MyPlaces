
import UIKit

class MainTableVC: UITableViewController {
    

    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! CustomCell
        cell.nameLabel?.text = places[indexPath.row].name
        cell.locationLabel.text = places[indexPath.row].location
        cell.imagePlace?.image = UIImage(named: places[indexPath.row].image)
        cell.imagePlace?.layer.cornerRadius = 20
        cell.imageCategory.image = UIImage(named: places[indexPath.row].type)
        
    
        cell.imagePlace.clipsToBounds = true
        return cell
    }
    
}
