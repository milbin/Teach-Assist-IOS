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
    
    //number of cells in tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if response == nil{
            return 0
        }
        return response!.count
    }
    //number of headers
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //name of header
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Notifications"
    }
    //customize the header to make the background white and the text match the pinkish teachassist theme colour
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = UIColor(red:51/255, green: 51/255, blue: 61/255, alpha: 1.0)
        view.tintColor = UIColor(red:0, green:0, blue:0, alpha:0) //gray colour w no tint
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
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
        let cell = Bundle.main.loadNibNamed("SettingsTableViewCell", owner: self, options: nil)?.first as! SettingsTableViewCell
        cell.initCheckbox()
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "Course" + String(indexPath.row))
        if currentPreferenceExists != nil{ //preference does exist
            let currentPreferenceValue = Preferences.bool(forKey: "Course" + String(indexPath.row))
            cell.setCheckBoxButton(value: currentPreferenceValue)
        }
        let dict = response![indexPath.row]
        
        cell.Description.text = "Notification Toggle for: " + (dict["course"] as! String)
        cell.Title.text = "Period " + String(indexPath.row + 1)
        cell.backgroundColor = UIColor(red:51/255, green: 51/255, blue: 61/255, alpha: 0.0)
        
        return cell
    }
    //this is the onclick method for the tableview cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "Course" + String(indexPath.row))
        if currentPreferenceExists != nil{ //preference does exist
            let currentPreferenceValue = Preferences.bool(forKey: "Course" + String(indexPath.row))
            Preferences.set(!currentPreferenceValue, forKey: "Course" + String(indexPath.row))
            print("Set " + "Course" + String(indexPath.row) + " as " + String(!currentPreferenceValue))
        }else{
            Preferences.set(true, forKey: "Course" + String(indexPath.row))
        }
        Preferences.synchronize()
        let cell = tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
        cell.toggleCheckbox()
        
    }


    

}
