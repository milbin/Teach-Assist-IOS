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
            //  Save to disk
            Preferences.synchronize()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
            present(vc, animated: true, completion: nil)
            
        } else if indexPath.row == cells["settings"]{
            print("settings pressed")
            //self.performSegue(withIdentifier: "settingsSegue", sender: self)
            print(self.parent)
            if let drawerController = self.parent!.parent as? KYDrawerController {
                drawerController.setDrawerState(.closed, animated: true)
                print((drawerController.mainViewController as! UINavigationController).viewControllers)
                (drawerController.mainViewController as! UINavigationController).viewControllers[0].performSegue(withIdentifier: "settingsSegue", sender: nil)
            }
            
            
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HistorySegue" {
            
        }
    }

}
