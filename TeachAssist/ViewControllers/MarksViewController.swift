import UIKit

class MarksViewController: UITableViewController {
    var response:[NSMutableDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MARKS VIEW")
        
        
    }
    
    //number of cells in tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    //set the height of the tableview header bc it adds more whitespace at the top
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 50
    }
    //set the height of tableview rows
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    //this method will load in the cells when the tableview is first created
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell = Bundle.main.loadNibNamed("SettingsTableViewCell", owner: self, options: nil)?.first as! SettingsTableViewCell
        cell.initCheckbox()
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "Course" + String(indexPath.row))
        if currentPreferenceExists != nil{ //preference does exist
            let currentPreferenceValue = Preferences.bool(forKey: "Course" + String(indexPath.row))
            cell.setCheckBoxButton(value: currentPreferenceValue)
        }
        let dict = response![indexPath.row]
        
        cell.Description.text = "Notification Toggle for: " + (dict["course"] as! String)
        cell.Title.text = "Period " + String(indexPath.row + 1)*/
        var cell = UITableViewCell()
        
        
        return cell
    }
    //this is the onclick method for the tableview cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    
    
    
}
