//
//  DrawerViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-03-31.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewControllerParent: UIViewController {
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet var dividerView: UIView!
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
                let textAttributes = [NSAttributedString.Key.foregroundColor:lightThemeBlack]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                self.view.backgroundColor = lightThemeWhite
                dividerView.tintColor = lightThemeLightBlack
                appTitleLabel.textColor = lightThemeBlack
                
            }
        }
    }
}
