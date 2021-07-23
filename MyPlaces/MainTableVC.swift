
import UIKit

class MainTableVC: UITableViewController {
    
    let places: [String] = ["KFC","McDonalds",
                            "Burger Heroes","ПиццаСушиВок",
                            "Тануки","Северяне",
                            "ЙУХ","Хачапури и Вино"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = places[indexPath.row]
        cell.imageView?.image = UIImage(named: places[indexPath.row])
        return cell
    }
}
