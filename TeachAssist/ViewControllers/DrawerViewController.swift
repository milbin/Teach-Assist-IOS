//
//  DrawerViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-03-31.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewController: UITableViewController {
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeBlue = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemePink = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)

    @IBOutlet weak var settingsCell: UITableViewCell!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var logoutIcon: UIImageView!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var feedbackIcon: UIImageView!
    @IBOutlet weak var openInLabel: UILabel!
    @IBOutlet weak var openInIcon: UIImageView!
    @IBOutlet weak var releaseNotesIcon: UIImageView!
    @IBOutlet weak var releaseNotesLabel: UILabel!
    
    var cells = ["settings":0, "bug report":1, "open in":2, "release notes":3, "logout":4]
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
                let textAttributes = [NSAttributedString.Key.foregroundColor:lightThemeBlack]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                settingsLabel.textColor = lightThemeBlack
                settingsIcon.image = UIImage(named: "settings-dark")
                feedbackLabel.textColor = lightThemeBlack
                feedbackIcon.image = UIImage(named: "bug-dark")
                openInLabel.textColor = lightThemeBlack
                openInIcon.image = UIImage(named: "open-in-dark")
                releaseNotesLabel.textColor = lightThemeBlack
                releaseNotesIcon.image = UIImage(named: "info-dark")
                logoutLabel.textColor = lightThemeBlack
                logoutIcon.image = UIImage(named: "logout-dark")
                settingsLabel.superview?.backgroundColor = lightThemeWhite
                feedbackLabel.superview?.backgroundColor = lightThemeWhite
                openInLabel.superview?.backgroundColor = lightThemeWhite
                logoutLabel.superview?.backgroundColor = lightThemeWhite
                releaseNotesLabel.superview?.backgroundColor = lightThemeWhite
                self.view.backgroundColor = lightThemeWhite
            }
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == cells["logout"]{
            print("Logging out")
            let Preferences = UserDefaults.standard
            Preferences.set("", forKey: "username")
            Preferences.set("", forKey: "password")
            DispatchQueue.main.async(execute: {
                let Preferences = UserDefaults.standard
                if let token = Preferences.string(forKey: "token"){
                    let sr = SendRequest()
                    let serverPassword = auth()
                    let dict = ["token":token,
                                "auth":serverPassword.getAuth(),
                                "purpose":"delete",
                                ]
                    let URL = "https://benjamintran.me/TeachassistAPI/"
                    //print(sr.SendJSON(url: URL, parameters: dict))
                }
            })
            
            //  Save to disk
            Preferences.synchronize()
            let ta = TA()
            let username = Preferences.string(forKey: "username")
            ta.userDidLogout(forUsername: username!)
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
            //present(vc, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController = vc
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
        }else if indexPath.row == cells["settings"]{
            print("settings pressed")
            
            if let drawerController = self.parent!.parent as? KYDrawerController {
                drawerController.setDrawerState(.closed, animated: true)
                (drawerController.mainViewController as! UINavigationController).viewControllers[0].performSegue(withIdentifier: "settingsSegue", sender: nil)
            }
            
            
        }else if indexPath.row == cells["bug report"]{
            print("bug report pressed")

            let email = "taappyrdsb@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }else if indexPath.row == cells["open in"]{
            print ("open in pressed")
            
            let url = URL(string:"https://ta.yrdsb.ca/yrdsb/")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }else if indexPath.row == cells["release notes"]{
            if let drawerController = self.parent!.parent as? KYDrawerController {
                drawerController.setDrawerState(.closed, animated: true)
                ((drawerController.mainViewController as! UINavigationController).viewControllers[0] as? MainViewController)?.showReleaseNotes()
            }
        }

    }
    
}
