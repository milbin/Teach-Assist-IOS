//
//  ViewController.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import UICircularProgressRing

class MainViewController: UIViewController {
    var courseList = [CourseView]()

    
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var StackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AverageBar: UICircularProgressRing!
    override func viewDidLoad() {
        super.viewDidLoad()
        AverageBar.font = UIFont.boldSystemFont(ofSize: 25.0)
        AverageBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //get ta data
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
        var response = ta.GetTaData(username: username!, password: password!) ?? nil
        self.navigationItem.title = "Student: "+username!;
        
        //add courses to main view
        if response == nil{
            return //TODO raise network connecttion error
        }
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        for (i, course) in response!.enumerated(){
            
            var courseView = CourseView(frame: CGRect(x: 0, y: 0, width: 415, height: 160))
            if let mark = course["mark"] as? CGFloat{
                courseView.ProgressBar.value = mark
            }else{
                courseView.ProgressBar.isHidden = true
            }
            courseView.PeriodNumber.text = "Period: \(i+1)"
            if course["Room_Number"] != nil{
                courseView.RoomNumber.text = "Room: \(course["Room_Number"]!)"
            }
            if course["course"] != nil{
                courseView.CourseCode.text = (course["course"] as! String)
            }
            if course["Course_Name"] != nil{
                courseView.CourseName.text = (course["Course_Name"] as! String)
            }
            StackView.addArrangedSubview(courseView)
            
            /*let rectShape = CAShapeLayer()
            rectShape.bounds = courseView.frame
            rectShape.position = courseView.center
            rectShape.path = UIBezierPath(roundedRect: courseView.bounds, byRoundingCorners: [.bottomLeft , .bottomRight , .topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
            courseView.layer.mask = rectShape*/
            
            StackViewHeight.constant = StackViewHeight.constant + 175
            
        }
        AverageBar.value = CGFloat(ta.CalculateAverage(response: response!))
        
    }
    
}

