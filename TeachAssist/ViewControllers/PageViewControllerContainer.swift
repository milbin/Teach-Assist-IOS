//
//  PageViewControllerContainer.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-03-21.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import Foundation
import UIKit
class PageViewControllerContainer: UIViewController{
    var Mark:Double? = nil
    var courseNumber:Int? = nil
    var ta:TA? = nil
    var vcTitle:String? = nil
    var lightThemeBlack:UIColor? = nil
    var unhighlightedTextColour:UIColor? = nil
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageIndicator: UIView!
    @IBOutlet weak var assignmentsLabel: UILabel!
    @IBOutlet weak var statisticsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //theme colours
        var lightThemeEnabled = false
        unhighlightedTextColour = UIColor(red: 72/255, green: 72/255, blue: 87/255, alpha: 1)
        lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
        
        //check for light theme
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
            if(lightThemeEnabled){
                //set colours
                unhighlightedTextColour = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
                lightThemeBlack = UIColor(red:0/255, green:0/255, blue: 0/255, alpha:1)
                
            }
        }
        
        pageIndicator.layer.borderWidth = 2
        pageIndicator.layer.cornerRadius = 8
        pageIndicator.layer.borderColor = unhighlightedTextColour!.cgColor
        
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "CourseInfoPageViewController") as! CourseInfoPageViewController
        vc.Mark = Mark
        vc.courseNumber = courseNumber
        vc.ta = ta
        vc.vcTitle = vcTitle
        addChild(vc)
        //vc.view.frame = ...  // or, better, turn off `translatesAutoresizingMaskIntoConstraints` and then define constraints for this subview
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    
}
