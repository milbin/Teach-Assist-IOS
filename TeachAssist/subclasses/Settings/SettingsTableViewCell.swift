//
//  SettingsTableViewCell.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-04-16.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
       
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var CheckBoxButton: UIButton!
    @IBOutlet weak var Description: UILabel!
    
    func initCheckbox(){
        let imageNormal = UIImage(named: "checkbox-blank-outline")
        CheckBoxButton.setImage(imageNormal, for: .normal)
        let imageSelected = UIImage(named: "checkbox-marked")
        CheckBoxButton.setImage(imageSelected, for: .selected)
    }
    
    func toggleCheckbox(){
        CheckBoxButton.isSelected = !CheckBoxButton.isSelected

    }
    
    func setCheckBoxButton(value: Bool){
        CheckBoxButton.isSelected = value
    }
    
        
        
    
    
}
