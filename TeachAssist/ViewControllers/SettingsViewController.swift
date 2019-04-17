//
//  SettingsViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-04-03.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    var response:[NSMutableDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Settings"
        //let nib = UINib.init(nibName: "SettingsTableViewCell", bundle: nil)
        //tableView.register(nib, forCellReuseIdentifier: "SettingsTableViewCell")
    }
    
    // MARK: - UITableView delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response!.count
      
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Notifications"
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("SettingsTableViewCell", owner: self, options: nil)?.first as! SettingsTableViewCell
        
        let dict = response![indexPath.row]
        
        cell.Description.text = "Notification Toggle for: " + (dict["course"] as! String)
        cell.Title.text = "Period " + String(indexPath.row + 1)
        
        
        return cell
    }


    

}
