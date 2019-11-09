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
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeBlue = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemePink = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)
    override func viewDidLoad() {
        super.viewDidLoad()
        //check for light theme
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
            if(lightThemeEnabled){
                //set colours
                lightThemeLightBlack = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
                lightThemeWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                lightThemeBlack = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                lightThemeBlue = UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1.0)
                lightThemePink = UIColor(red: 114/255, green: 159/255, blue: 255/255, alpha: 1.0)
                
                self.navigationController?.navigationBar.barTintColor = lightThemeWhite
                navigationItem.backBarButtonItem?.tintColor = lightThemeBlack
                navigationController!.navigationBar.barStyle = UIBarStyle.black
                self.view.backgroundColor = lightThemeWhite
                
            }
        }
    }
    
    //number of cells in tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    //number of headers
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //name of header
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Theme"
    }
    //customize the header to make the background white and the text match the pinkish teachassist theme colour
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = lightThemeWhite
        view.tintColor = UIColor(red:0, green:0, blue:0, alpha:0) //transparent
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = lightThemePink //teachassist themed pink
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
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            let currentPreferenceValue = Preferences.bool(forKey: "LightThemeEnabled")
            cell.setCheckBoxButton(value: currentPreferenceValue)
        }else{
            Preferences.set(false, forKey: "LightThemeEnabled")
        }
        
        cell.Description.text = "Light theme enabled"
        cell.Title.text = "Light Theme "
        cell.Title.textColor = lightThemeBlack
        cell.Description.textColor = lightThemeBlack
        cell.backgroundColor = lightThemeWhite
        
        return cell
    }
    //this is the onclick method for the tableview cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            let currentPreferenceValue = Preferences.bool(forKey: "LightThemeEnabled")
            Preferences.set(!currentPreferenceValue, forKey: "LightThemeEnabled")
            if(!currentPreferenceValue){ //light theme enabled
                if #available(iOS 10.3, *) {
                    if UIApplication.shared.supportsAlternateIcons{
                        UIApplication.shared.setAlternateIconName("light", completionHandler: { (error) in
                        })
                    }
                }
            }else{
                if #available(iOS 10.3, *) {
                    if UIApplication.shared.supportsAlternateIcons{
                        UIApplication.shared.setAlternateIconName("dark", completionHandler: { (error) in
                        })
                    }
                }
            }
        }
        Preferences.synchronize()
        let cell = tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
        cell.toggleCheckbox()
        //alert
        let alert = UIAlertController(title: "Please Restart Application", message: "Theme changes will not come into effect until after the application is fully closed and restarted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
        
    }    

}
