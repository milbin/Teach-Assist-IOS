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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    func initButton(){
        addTarget(self, action: #selector(LoginButton.buttonPressed), for: .touchUpInside)
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        
    }
    @objc func buttonPressed(){
        print("Login")
        let Preferences = UserDefaults.standard
        let KeyUsername = "username"
        let KeyPassword = "password"
        let Username = usernameTextField.text
        let Password = passwordTextField.text
        if( Username == "" || Password == ""){
            //TODO riase some error
            print("no username / password entered")
        }else{
        
            Preferences.set(Username, forKey: KeyUsername)
            Preferences.set(Password, forKey: KeyPassword)
            
            //  Save to disk
            Preferences.synchronize()
            print(Preferences.string(forKey: KeyUsername)!)
            print(Preferences.string(forKey: KeyPassword)!)
        }
        
        
    }
    

}
