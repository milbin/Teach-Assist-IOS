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

    @IBOutlet weak var settingsCell: UITableViewCell!
    var cells = ["settings":0, "logout":1, "bug report":2]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == cells["logout"]{
            print("Logging out")
            let Preferences = UserDefaults.standard
            Preferences.set("", forKey: "username")
            Preferences.set("", forKey: "password")
            let sr = SendRequest()
            let serverPassword = auth()
            let dict = ["token":Preferences.string(forKey: "token")!,
                        "auth":serverPassword.getAuth(),
                        "purpose":"delete",
                        ]
            let URL = "https://benjamintran.me/TeachassistAPI/"
            sr.SendJSON(url: URL, parameters: dict)
            
            //  Save to disk
            Preferences.synchronize()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
            present(vc, animated: true, completion: nil)
            
        } else if indexPath.row == cells["settings"]{
            print("settings pressed")
            
            if let drawerController = self.parent!.parent as? KYDrawerController {
                drawerController.setDrawerState(.closed, animated: true)
                (drawerController.mainViewController as! UINavigationController).viewControllers[0].performSegue(withIdentifier: "settingsSegue", sender: nil)
            }
            
            
        }else if indexPath.row == cells["bug report"]{
            let email = "TaAppYRDSB@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    
    }
    

}
