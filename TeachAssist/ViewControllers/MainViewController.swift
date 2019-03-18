//
//  ViewController.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    var courseList = [CourseView]()

    
    @IBOutlet weak var StackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /*var StackView = UIStackView()
        StackView.axis = .vertical
        StackView.distribution = .equalSpacing
        StackView.alignment = .center
        StackView.spacing = 5
        StackView.translatesAutoresizingMaskIntoConstraints = false
        StackView.contentMode = .scaleAspectFit
        view.addSubview(StackView)
        
        //autolayout the stack view - pin 30 up 20 left 20 right 30 down
        let viewsDictionary = ["stackView":StackView]
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-20-[stackView]-20-|",  //horizontal constraint 20 points from left and right side
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-"+self.navigationItem.frame.height+"-[stackView]-1-|", //vertical constraint 30 points from top and bottom
            options: NSLayoutConstraint.FormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary)
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)*/
        
        var courseView = CourseView(frame: CGRect(x: 0, y: 0, width: 350, height: 150))
        courseView.contentMode = .scaleAspectFit
        StackView.addArrangedSubview(courseView)
        

        
        
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

