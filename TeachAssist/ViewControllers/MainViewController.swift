//
//  ViewController.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var StackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*for i in [1,2]{
            let controller = storyboard!.instantiateViewController(withIdentifier: "CourseView")
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            StackView.addSubview(controller.view)
            
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                controller.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
                ])
            
            controller.didMove(toParent: self)
        }*/
        var courseView:UIView = CourseView(frame: self.StackView.bounds)
        StackView.addSubview(courseView)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let ta = TA()
        let Preferences = UserDefaults.standard
        var username = Preferences.string(forKey: "username")
        var password = Preferences.string(forKey: "password")
        if(username == nil || password == nil){
            //switch to login view
            print("things")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
            present(vc, animated: true, completion: nil)
            return
        }
        ta.GetTaData(username: username!, password: password!)
        self.navigationItem.title = "TeachAssist";
    }
    
}

