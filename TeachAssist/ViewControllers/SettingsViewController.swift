//
//  SettingsViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-04-07.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeBlue = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemePink = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)
    
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var teachassistProLabel: UILabel!
    @IBOutlet weak var teachassistProDescLabel: UILabel!
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
        //setup upgrade button
        let gradientColors: [CGColor] = [lightThemeBlue.cgColor, lightThemePink.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        gradientLayer.frame = upgradeButton.bounds
        gradientLayer.cornerRadius = 5
        upgradeButton.layer.insertSublayer(gradientLayer, at: 0)
        
        //setup Ta pro labels
        teachassistProLabel.superview?.backgroundColor = lightThemeWhite
        teachassistProLabel.textColor = lightThemeBlack
        teachassistProDescLabel.textColor = lightThemeBlack
        
        
    }
    
    
}
