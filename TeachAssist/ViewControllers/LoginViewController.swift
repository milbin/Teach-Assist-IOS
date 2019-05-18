//
//  LoginViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-02-21.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import KYDrawerController

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(LoginViewController.buttonPressed), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        let Preferences = UserDefaults.standard
        var username = Preferences.string(forKey: "username")
        var password = Preferences.string(forKey: "password")
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
            let ta = TA()
            if ta.CheckCredentials(username: Username!, password: Password!){
            
                Preferences.set(Username!, forKey: KeyUsername)
                Preferences.set(Password!, forKey: KeyPassword)
                //  Save to disk
                Preferences.synchronize()
                print(Preferences.string(forKey: KeyUsername)!)
                print(Preferences.string(forKey: KeyPassword)!)
                let token = Preferences.string(forKey: "token")
                
                let sr = SendRequest()
                let dict = ["username":Username!,
                            "password":Password!,
                            "platform":"IOS",
                            "token":token!,
                            "auth":"taappyrdsb123!",
                            "purpose":"register",
                            ]
                let URL = "https://benjamintran.me/TeachassistAPI/"
                print(sr.SendJSON(url: URL, parameters: dict))
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController   = storyboard.instantiateViewController(withIdentifier: "MainView") as UIViewController
                let drawerViewController = storyboard.instantiateViewController(withIdentifier: "DrawerView") as UIViewController
                let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 300)
                drawerController.mainViewController = mainViewController
                drawerController.drawerViewController = drawerViewController
                UIApplication.shared.keyWindow?.rootViewController = drawerController
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }else{
                //TODO show some dialog saying wrong user pass
                print("WRONG USERNAME/PASSWORD")
            }
            
        }
        
        
    }
    
}
