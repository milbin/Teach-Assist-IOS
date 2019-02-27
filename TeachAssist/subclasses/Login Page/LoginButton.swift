//
//  LoginButton.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-02-22.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

    override init(frame:CGRect){
        super.init(frame:frame)
        initButton()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initButton()
    }
    
    func initButton(){
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        
    }
    
    

}
