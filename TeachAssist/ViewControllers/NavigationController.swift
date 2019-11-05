//
//  NavigationController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-11-05.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
class NavigationController: UINavigationController {
    var lightThemeEnabled = false
    
    override func viewDidLoad() {
        //check for light theme
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
            if(lightThemeEnabled){
                
            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if(lightThemeEnabled){
            return .default
        }else{
            return .lightContent
        }
    }
}
