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
    @IBOutlet weak var StackViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        for i in 0...10{
        var courseView = CourseView(frame: CGRect(x: StackView.frame.origin.x, y: topBarHeight, width: 350, height: 150))
        courseView.ProgressBar.value = 36.7
        StackView.addArrangedSubview(courseView)
            
        let rectShape = CAShapeLayer()
        rectShape.bounds = courseView.frame
        rectShape.position = courseView.center
        rectShape.path = UIBezierPath(roundedRect: courseView.bounds, byRoundingCorners: [.bottomLeft , .bottomRight , .topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        courseView.layer.mask = rectShape
        
        StackViewHeight.constant = StackViewHeight.constant + 165
        }
        
        
        
 
        /*
        for i in 0...20 {
            let greenView = UIView()
            greenView.backgroundColor = .green
            StackView.addArrangedSubview(greenView)
            greenView.translatesAutoresizingMaskIntoConstraints = false
            // Doesn't have intrinsic content size, so we have to provide the height at least
            greenView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            // Label (has instrinsic content size)
            let label = UILabel()
            label.backgroundColor = .orange
            label.text = "I'm label \(i)."
            label.textAlignment = .center
            StackView.addArrangedSubview(label)
        }*/

        
        
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

