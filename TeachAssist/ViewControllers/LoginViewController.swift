//
//  LoginViewController.swift
//  TeachAssist
//
//  Created by ben tran on 2019-02-21.
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
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        loginButton.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 5)
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string:"Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:51/255, green: 51/255, blue: 61/255, alpha: 1.0)]) //to make the colour of the placeholder gray, not entirely working for some reason
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red:51/255, green: 51/255, blue: 61/255, alpha: 1.0)])
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func buttonPressed(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();

        


        let Preferences = UserDefaults.standard
        let KeyUsername = "username"
        let KeyPassword = "password"
        let Username = usernameTextField.text
        let Password = passwordTextField.text
        if( Username == "" || Password == ""){
            let alert = UIAlertController(title: "Error: Missing username or password", message: "Please enter a username and password and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }else{
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: {

                let ta = TA()
                if ta.CheckCredentials(username: Username!, password: Password!){
                    
                
                    Preferences.set(Username!, forKey: KeyUsername)
                    Preferences.set(Password!, forKey: KeyPassword)
                    //  Save to disk
                    Preferences.synchronize()
                    print(Preferences.string(forKey: KeyUsername)!)
                    print(Preferences.string(forKey: KeyPassword)!)
                    let token = Preferences.string(forKey: "token")
                    if token != nil{
                        let sr = SendRequest()
                        let serverPassword = auth()
                        let dict = ["username":Username!,
                                    "password":Password!,
                                    "platform":"IOS",
                                    "token":token!,
                                    "auth":serverPassword.getAuth(),
                                    "purpose":"register",
                                    ]
                        let URL = "https://benjamintran.me/TeachassistAPI/"
                        //print(sr.SendJSON(url: URL, parameters: dict))
                    }
                    
                    
                    self.dismiss(animated: false, completion: nil)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainViewController   = storyboard.instantiateViewController(withIdentifier: "MainView") as UIViewController
                    let drawerViewController = storyboard.instantiateViewController(withIdentifier: "DrawerView") as UIViewController
                    let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 300)
                    drawerController.mainViewController = mainViewController
                    drawerController.drawerViewController = drawerViewController
                    UIApplication.shared.keyWindow?.rootViewController = drawerController
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                }else{
                    self.dismiss(animated: false, completion: {
                        let alert = UIAlertController(title: "Error: Invalid username or password", message: "Please check your internet connection and try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        })
                }


                })
            
            
        }
        
        
    }
    
    
    
}
