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

class MainViewController: UIViewController {
    var courseList = [CourseView]()
    var userIsEditing = false
    var response:[NSMutableDictionary]? = nil
    var hasViewStarted = false //this variable will check to make sure that the view hasnt started before so that courses arent re-added every time the nav drawer is triggered.
    var refreshControl:UIRefreshControl? = nil
    let ta = TA()
    
    
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
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "HamburgerIcon"), style: .plain, target: self, action: #selector(OnNavButtonPress))//add nav button as the onClick method
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("Notifications not allowed")
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Don't forget"
        content.body = "Buy some milk"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true) // 15 minutes
        
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Something went wrong1")
            }
        })
        var displayString = "Current Pending Notifications "
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            (requests) in
            displayString += "count:\(requests.count)\t"
            for request in requests{
                displayString += request.identifier + "\t"
            }
            print(displayString)
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if hasViewStarted == true{
            return
        }
        //setup refresh controller to allow main view to be refreshed
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self,
                                 action: #selector(OnRefresh),
                                 for: .valueChanged)
        scrollView.refreshControl = refreshControl
        StackView.addBackground(color: UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0))
        

        hasViewStarted = true
        //get ta data
        
        let Preferences = UserDefaults.standard
        var username = Preferences.string(forKey: "username")
        var password = Preferences.string(forKey: "password")
        if(username == nil || password == nil){
            //switch to login view
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoginView") as UIViewController
            present(vc, animated: true, completion: nil)
            return
        }
        response = ta.GetTaData(username: username!, password: password!) ?? nil
        self.navigationItem.title = "Student: "+username!
        
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
            return //TODO raise network connecttion error
        }
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        for (i, course) in response!.enumerated(){
            
            var courseView = CourseView(frame: CGRect(x: 0, y: 0, width: 350, height: 160))
            if let mark = course["mark"] as? CGFloat{
                courseView.ProgressBar.value = mark
            }else{
                courseView.ProgressBar.isHidden = true
                courseView.NATextView.isHidden = false
                
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
            StackView.addArrangedSubview(courseView as UIView)
            
            courseView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
            courseList.append(courseView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnCourseSelected))
            courseView.addGestureRecognizer(tapGesture)
            
            StackViewHeight.constant = StackViewHeight.constant + 170
            
        }
        AverageBar.startProgress(to: CGFloat(ta.CalculateAverage(response: response!)), duration: 1.5)
        
        if refreshControl!.isRefreshing{
            refreshControl!.endRefreshing()
        }
        
        
        
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
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @objc func OnEditButtonPress(sender: UIBarButtonItem){
    print("edit Button pressed")
        if userIsEditing{
            userIsEditing = false
            for course in courseList{
                course.TrashButton.isHidden = true
            }
        }else{
            userIsEditing = true
            for course in courseList{
                course.TrashButton.isHidden = false
            }
        }
        
        var displayString = "Current Pending Notifications "
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            (requests) in
            displayString += "count:\(requests.count)\t"
            for request in requests{
                displayString += request.identifier + "\t"
            }
            print(displayString)
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
        var courseNumber = -1
        for course in StackView.arrangedSubviews{
            if view == course{
                response!.remove(at: courseNumber)
                AverageBar.value = CGFloat(ta.CalculateAverage(response: response!))
            }
            courseNumber += 1
        }
        
        view?.isHidden = true
        view?.removeFromSuperview()
        StackView.layoutIfNeeded()
        StackViewHeight.constant -= 170
        
        
        
        
        }
    
    @objc func OnRefresh() {
        print("refreshed")
        var courseNumber = -1
        for view in StackView.arrangedSubviews{
            if courseNumber >= 0{
                view.isHidden = true
                view.removeFromSuperview()
                StackViewHeight.constant -= 170
            }
            courseNumber += 1
        }
        AverageBar.startProgress(to: 0.0, duration: 0)
        hasViewStarted = false
        viewDidAppear(true)
        
    }
    
    @objc func OnCourseSelected(gesture: UIGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            gesture.view!.alpha = 0.65
            gesture.view!.alpha = 1
        })
        var courseNumber = -1
        for course in StackView.arrangedSubviews{
            if gesture.view == course{
                break
            }
            courseNumber += 1
        }
        performSegue(withIdentifier: "MarksViewSegue", sender: [response![courseNumber]["mark"], Double(courseNumber), response![courseNumber]["course"]])
    }
    
    
    
}



