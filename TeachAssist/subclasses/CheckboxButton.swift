//
//  CheckboxButton.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-02-21.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class CheckboxButton: UIButton {

    var isChecked =  true
    
    override init(frame:CGRect){
        super.init(frame:frame)
        initButton()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initButton()
    }

    func initButton(){
        print("init")
        addTarget(self, action: #selector(CheckboxButton.buttonPressed), for: .touchUpInside)
        isSelected = true
        let imageSelected = UIImage(named: "checkbox-marked")
        setImage(imageSelected, for: .selected)
        let imageNormal = UIImage(named: "checkbox-blank-outline")
        setImage(imageNormal, for: .normal)
        
        
    }
    @objc func buttonPressed(){
        if(isSelected){
            isSelected = false
        }else{
            isSelected = true
        }
        
    }
}
