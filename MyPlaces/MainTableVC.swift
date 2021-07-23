
import UIKit

class MainTableVC: UITableViewController {
    
    let places: [String] = ["KFC","McDonalds",
                            "Burger Heroes","Якитория",
                            "Тануки","Рыба моя",
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! CustomCell
        cell.nameLabel?.text = places[indexPath.row]
        cell.imagePlace?.image = UIImage(named: places[indexPath.row])
        cell.imagePlace?.layer.cornerRadius = 10
        cell.imageCategory.image = UIImage(named: "Ролл 1")
        return cell
    }
    
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    
    
    
}
