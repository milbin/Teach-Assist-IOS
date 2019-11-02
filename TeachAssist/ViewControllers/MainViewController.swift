//
//  ViewController.swift
//  TeachAssist
//
//  Created by Ben Tran on 2019-02-01.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import UICircularProgressRing
import KYDrawerController
import UserNotifications
import Crashlytics
import PopupDialog

class MainViewController: UIViewController {
    var courseList = [CourseView]()
    var userIsEditing = false
    var response:[NSMutableDictionary]? = nil
    var hasViewStarted = false
    //this variable will check to make sure that the view hasnt started before so that courses arent re-added every time the nav drawer is triggered.
    var refreshControl:UIRefreshControl? = nil
    let ta = TA()
    var numberOfRemovedCourses = 0

    @IBOutlet weak var noCoursesTV: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var StackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AverageBar: UICircularProgressRing!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        AverageBar.font = UIFont.boldSystemFont(ofSize: 25.0)
        AverageBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(OnEditButtonPress))//add edit button as the onClick method
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Gilroy-Regular", size: 17)!,
            NSAttributedString.Key.foregroundColor: UIColor.white],
        for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "HamburgerIcon"), style: .plain, target: self, action: #selector(OnNavButtonPress))//add nav button as the onClick method
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        //setup refresh controller to allow main view to be refreshed
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self,
                                  action: #selector(OnRefresh),
                                  for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        //ask for ratings
        let Preferences = UserDefaults.standard
        let firstLaunch = Preferences.string(forKey: "firstLaunch")
        if(firstLaunch == nil || true){
            Preferences.set("true", forKey: "firstLaunch")
            let title = "🎉 Announcing 2 New Features! 🎉"
            let message = """
            We've received a lot of positive feedback from this past Monday's redesign update, and we'd like to announce the addition of another 2 features:

            LIGHT MODE
            A MARKS CALCULATOR

            The light mode option can be found in settings, while the marks calculator can be found at the bottom of each course page. We hope you enjoy!
            """
            let image = UIImage(named: "ta_logo_v3")
            let popup = PopupDialog(title: title, message: message, image: image)
            let buttonOne = PopupDialogButton(title: "Ok", dismissOnTap: true) {
                print("What a beauty!")
            }
            popup.addButtons([buttonOne])
            self.present(popup, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if hasViewStarted == true{
            return
        }
        
        
        for view in StackView.arrangedSubviews{
            view.layoutIfNeeded()
        }
        
        AverageBar.font = UIFont(name: "Gilroy-Bold", size: 30)!
        AverageBar.fontColor = UIColor.white
        scrollView.backgroundColor = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
        StackView.addBackground(color: UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1))

        hasViewStarted = true
        //get ta data
        let Preferences = UserDefaults.standard
        let username = Preferences.string(forKey: "username")
        let password = Preferences.string(forKey: "password")
        print(username)
        print(password)
        if(username == nil || password == nil){
            //switch to login view
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
            present(vc, animated: true, completion: nil)
            return
        }
        response = ta.GetTaData(username: username!, password: password!) ?? nil
        print(response)
        self.navigationItem.title = "Student: "+username!
        if response == nil{
            let alert = UIAlertController(title: "Could not reach Teachassist", message: "Please check your internet connection and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action:UIAlertAction!) in
                self.OnRefresh()
            }))
            self.present(alert, animated: true)
            return
        }
        
        //add default preferences for notifications
        for i in 0...response!.count{
            let currentPreferenceExists = Preferences.object(forKey: "Course" + String(i))
            if currentPreferenceExists == nil{ //if preference does not exist
                Preferences.set(true, forKey: "Course" + String(i))
            }
        }
        Preferences.synchronize()
        
        //add courses to main view
        if response == nil{
            let alert = UIAlertController(title: "Could not reach Teachassist", message: "Please check your internet connection and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action:UIAlertAction!) in
                self.OnRefresh()
            }))
            self.present(alert, animated: true)
            return
        }
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        for (i, course) in response!.enumerated(){
            
            var courseView = CourseView(frame: CGRect(x: 0, y: 0, width: 350, height: 130))
            if let mark = (course["mark"] as? CGFloat){
                print(mark)
                courseView.ProgressBar.value = mark
            }else{
                courseView.ProgressBar.isHidden = true
                courseView.NATextView.isHidden = false
                courseView.isUserInteractionEnabled = false
                
            }
            
            courseView.PeriodNumber.text = "Period \(i+1)"
            if course["Room_Number"] != nil{
                courseView.RoomNumber.text = "— Rm \(course["Room_Number"]!)"
            }
            if course["course"] != nil{
                courseView.CourseCode.text = (course["course"] as! String)
            }
            if course["Course_Name"] != nil{
                if((course["course"]as! String).contains("SHAL")){
                    courseView.CourseName.text = "Spare"
                }else if((course["course"]as! String).contains("COP")){
                    courseView.CourseName.text = "Co-op"
                }else{
                    courseView.CourseName.text = (course["Course_Name"] as! String)
                }
            }
            StackView.addArrangedSubview(courseView as UIView)
            
            courseView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
            courseList.append(courseView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnCourseSelected))
            courseView.addGestureRecognizer(tapGesture)
            
            StackViewHeight.constant = StackViewHeight.constant + 140
            
        }
        
        if refreshControl!.isRefreshing{
            refreshControl!.endRefreshing()
        }
        
        self.AverageBar.startProgress(to: 0.0, duration: 0.01, completion: {
            var average = CGFloat(self.ta.CalculateAverage(response: self.response!))
                if average.description != "nan"{
                    self.AverageBar.startProgress(to: average, duration: 1)
                    self.noCoursesTV.isHidden = true
                }else if self.response!.count > 0{
                    self.noCoursesTV.isHidden = true
                }else{
                    self.noCoursesTV.isHidden = false
            }
            })

        
        UIView.animate(withDuration: 0.4, animations: {
            self.StackView.layoutIfNeeded()
        })
            
        
        
        
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SettingsViewController{
            let vc = segue.destination as? SettingsViewController
            vc?.response = response
        }else if segue.destination is MarksViewController{
            let vc = segue.destination as? MarksViewController
            if let senderList = (sender! as? [Any]){
                vc?.Mark = senderList[0] as! Double
                vc?.courseNumber = Int(senderList[1] as! Int)
                vc?.ta = ta
                vc?.vcTitle = senderList[2] as? String
            }
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Gilroy-Regular", size: 17)!,
            NSAttributedString.Key.foregroundColor: UIColor.white],
        for: .normal)
        navigationItem.backBarButtonItem = backItem
        // This will show in the next view controller being pushed
    }
    
    @objc func OnEditButtonPress(sender: UIBarButtonItem){
        print("edit Button pressed")
        if userIsEditing{
            userIsEditing = false
            self.setEditing(false, animated: true)
            for course in courseList{
                course.TrashButton.isHidden = true
            }
        }else{
            userIsEditing = true
            self.setEditing(true, animated: true)
            for course in courseList{
                course.TrashButton.isHidden = false
            }
        }       
        
    }
    
    @objc func OnNavButtonPress(sender: UIBarButtonItem){
        print("NAV Button pressed")
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    
    @objc func OnTrashButtonPress(sender: UIButton) {
        print("Pressed Trash Button")
        let view = sender.superview?.superview
        var courseNumber = 0
        for course in StackView.arrangedSubviews{
            if view == course{
                response!.remove(at: courseNumber)
                AverageBar.value = CGFloat(ta.CalculateAverage(response: response!))
            }
            courseNumber += 1
        }
        self.numberOfRemovedCourses += 1
        
        view?.isHidden = true
        view?.removeFromSuperview()
        StackView.layoutIfNeeded()
        StackViewHeight.constant -= 140
        
        
        
        
        }
    
    @objc func OnRefresh() {
        print("refreshed")
        
        
        var courseNumber = 0
        for view in StackView.arrangedSubviews{
            if courseNumber >= 0{
                view.isHidden = true
                view.removeFromSuperview()
                StackViewHeight.constant -= 140
            }
            courseNumber += 1
        }
        hasViewStarted = false
        StackView.layoutIfNeeded()
        viewDidAppear(false)
        
    }
    
    @objc func OnCourseSelected(gesture: UIGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            gesture.view!.alpha = 0.65
            gesture.view!.alpha = 1
        })
        var courseNumber = 0
        for course in StackView.arrangedSubviews{
            if gesture.view == course{
                break
            }
            courseNumber += 1
        }
        performSegue(withIdentifier: "MarksViewSegue", sender: [response![courseNumber]["mark"], Double(courseNumber+numberOfRemovedCourses), response![courseNumber]["course"]])
    }
    
    
}

extension UIView {
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            var cornerMask = UIRectCorner()
            if(corners.contains(.layerMinXMinYCorner)){
                cornerMask.insert(.topLeft)
            }
            if(corners.contains(.layerMaxXMinYCorner)){
                cornerMask.insert(.topRight)
            }
            if(corners.contains(.layerMinXMaxYCorner)){
                cornerMask.insert(.bottomLeft)
            }
            if(corners.contains(.layerMaxXMaxYCorner)){
                cornerMask.insert(.bottomRight)
            }
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornerMask, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}



