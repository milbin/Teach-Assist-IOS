//
//  PageViewControllerContainer.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-03-21.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
class PageViewControllerContainer: UIViewController{
    var Mark:Double? = nil
    var courseNumber:Int? = nil
    var ta:TA? = nil
    var vcTitle:String? = nil
    
    var lightThemeEnabled = false
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var unhighlightedTextColour = UIColor(red: 72/255, green: 72/255, blue: 87/255, alpha: 1)
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageIndicator: UIView!
    @IBOutlet weak var assignmentsLabel: UILabel!
    @IBOutlet weak var statisticsLabel: UILabel!
    @IBOutlet weak var indicatorContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //theme colours
        
        
        //check for light theme
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
            if(lightThemeEnabled){
                lightThemeEnabled = true
                //set colours
                unhighlightedTextColour = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
                lightThemeBlack = UIColor(red:0/255, green:0/255, blue: 0/255, alpha:1)
                lightThemeLightBlack = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
                lightThemeWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                indicatorContainerView.backgroundColor = lightThemeWhite
                assignmentsLabel.textColor = lightThemeBlack
                statisticsLabel.textColor = unhighlightedTextColour
                
            }
        }
        self.parent!.view.backgroundColor = lightThemeWhite
        self.view.backgroundColor = lightThemeWhite
        self.containerView.backgroundColor = lightThemeWhite
        pageIndicator.layer.borderWidth = 2
        pageIndicator.layer.cornerRadius = 8
        pageIndicator.layer.borderColor = unhighlightedTextColour.cgColor
        
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "CourseInfoPageViewController") as! CourseInfoPageViewController
        vc.Mark = Mark
        vc.courseNumber = courseNumber
        vc.ta = ta
        vc.vcTitle = vcTitle
        addChild(vc)
        
        containerView.addSubview(vc.view)
        vc.view.frame = containerView.frame
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.snp.makeConstraints { (make) in
            make.top.equalTo(containerView.snp.top)
            make.bottom.equalTo(containerView.snp.bottom)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing)
        }
        //vc.view.frame = ...  // or, better, turn off `translatesAutoresizingMaskIntoConstraints` and then define constraints for this subview
        vc.didMove(toParent: self)
    }
}
