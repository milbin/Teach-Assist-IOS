//
//  LoginViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-02-21.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(LoginViewController.buttonPressed), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
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
            //TODO check if username and password are valid
            
            Preferences.set(Username, forKey: KeyUsername)
            Preferences.set(Password, forKey: KeyPassword)
            
            //  Save to disk
            Preferences.synchronize()
            print(Preferences.string(forKey: KeyUsername)!)
            print(Preferences.string(forKey: KeyPassword)!)
            
        }
        
        
    }
    
}
