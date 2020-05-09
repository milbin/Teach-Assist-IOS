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
import StoreKit
import SwiftyJSON
import GoogleMobileAds
import AdSupport

class MainViewController: UIViewController {
    var courseList = [CourseView]()
    var userIsEditing = false
    var response:[NSMutableDictionary]? = nil
    var hasViewStarted = false
    //this variable will check to make sure that the view hasnt started before so that courses arent re-added every time the nav drawer is triggered.
    var refreshControl:UIRefreshControl? = nil
    let ta = TA()
    var numberOfRemovedCourses = 0
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeGreen = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemeBlue = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)
    
    @IBOutlet weak var noCoursesTV: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var StackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AverageBar: UICircularProgressRing!
    @IBOutlet weak var EditButton: UIBarButtonItem!
    @IBOutlet weak var hiddenCoursesBanner: UIView!
    @IBOutlet weak var hiddenCoursesBannerLabel: UILabel!
    @IBOutlet weak var hiddenCoursesBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var adView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //remove the 'shadow' property of the nav bar, this is the same as elevation in android
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:lightThemeBlack]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        //check for light theme
        let Preferences = UserDefaults.standard
        let currentPreferenceExists = Preferences.object(forKey: "LightThemeEnabled")
        if currentPreferenceExists != nil{ //preference does exist
            lightThemeEnabled = Preferences.bool(forKey: "LightThemeEnabled")
            if(lightThemeEnabled){
                //set colours
                lightThemeLightBlack = UIColor(red: 228/255, green: 228/255, blue: 235/255, alpha: 1.0)
                lightThemeWhite = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
                lightThemeBlack = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                lightThemeGreen = UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1.0)
                lightThemeBlue = UIColor(red: 114/255, green: 159/255, blue: 255/255, alpha: 1.0)
                
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                let textAttributes = [NSAttributedString.Key.foregroundColor:lightThemeBlack]
                navigationController?.navigationBar.titleTextAttributes = textAttributes
                self.AverageBar.outerRingColor = lightThemeLightBlack
                self.AverageBar.innerRingColor = lightThemeBlue
            }
        }
        scrollView.backgroundColor = lightThemeWhite
        StackView.addBackground(color: lightThemeWhite)
        self.view.backgroundColor = lightThemeWhite
        
        setNeedsStatusBarAppearanceUpdate()
        AverageBar.font = UIFont.boldSystemFont(ofSize: 25.0)
        AverageBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(OnEditButtonPress))//add edit button as the onClick method
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Gilroy-Regular", size: 17)!,
            NSAttributedString.Key.foregroundColor: lightThemeBlack],
                                                                  for: .normal)
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "hamburger-dark"), style: .plain, target: self, action: #selector(OnNavButtonPress)) //add nav button as the onClick method
        self.navigationController?.navigationBar.tintColor = lightThemeBlack
        //set right hamburger button
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        if(lightThemeEnabled){
            menuBtn.setImage(UIImage(named:"hamburger-dark"), for: .normal)
        }else{
            menuBtn.setImage(UIImage(named:"hamburger"), for: .normal)
        }
        menuBtn.addTarget(self, action: #selector(OnNavButtonPress), for: UIControl.Event.touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
        
        //setup refresh controller to allow main view to be refreshed
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self,
                                  action: #selector(OnRefresh),
                                  for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        Preferences.set(nil, forKey: "didAskForRating")
        /*//ask for ratings
        let didAskForRating = Preferences.string(forKey: "didAskForRating")
        if(didAskForRating == nil){
            Preferences.set(nil, forKey: "firstLaunch")
            Preferences.set(true, forKey: "didAskForRating")
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
        }*/
        if(UIDevice.modelName == "iPhone 5" || UIDevice.modelName == "iPhone 5s" || UIDevice.modelName == "iPhone 5c" ||
            UIDevice.modelName == "iPod Touch 5" || UIDevice.modelName == "iPod Touch 6" || UIDevice.modelName == "iPod5,1" ||
            UIDevice.modelName == "iPod7,1" || UIDevice.modelName == "iPhone SE"){
            hiddenCoursesBannerLabel.font = UIFont(name: hiddenCoursesBannerLabel.font.fontName, size: 12)
        }
        
        //setup Admob banner ad palcement
        adView.adUnitID = "ca-app-pub-3940256099942544/6300978111" //Admob test unit ID
        //adView.adUnitID = "ca-app-pub-6294253616632635/9795920506"
        adView.rootViewController = self
        print(ASIdentifierManager.shared().advertisingIdentifier)
        print("HERE")

        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if(lightThemeEnabled){
            return .default
        }else{
            return .lightContent
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if hasViewStarted == true{
            return
        }
        
        let Preferences = UserDefaults.standard
        if (Preferences.object(forKey: "isProUser") as? Bool) != true{
            //load ad in banner view
            loadBannerAd()
        }
        
        for view in StackView.arrangedSubviews{
            view.layoutIfNeeded()
        }
        
        AverageBar.font = UIFont(name: "Gilroy-Bold", size: 30)!
        AverageBar.fontColor = lightThemeBlack
        
        hasViewStarted = true
        //get ta data
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
        let didClearOfflineModeExists = Preferences.object(forKey: "didClearOfflineMode")
        if didClearOfflineModeExists == nil{
            Preferences.set(false, forKey: "didClearOfflineMode")
        }
        let didClearOfflineMode = Preferences.bool(forKey: "didClearOfflineMode")
        print(didClearOfflineMode)
        if !didClearOfflineMode{
            ta.userDidLogout(forUsername: username!)
            print("CLEARED OFFLINE")
            Preferences.set(true, forKey: "didClearOfflineMode")
        }
        
        //release notes popup dialog
        let firstLaunch = Preferences.string(forKey: "release notes 2.2.8")
        if(firstLaunch == nil){
            showReleaseNotes()
        }
        
        response = ta.GetTaData(username: username!, password: password!) ?? nil
        self.navigationItem.title = "Student: "+username!
        if response == nil{
            if let jsonData = ta.getCoursesFromJson(forUsername: username!) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.hiddenCoursesBanner.isHidden = false
                    self.hiddenCoursesBannerLabel.text = "No connection. Marks may not be updated while offline."
                    UIView.animate(withDuration: 0.5, animations: {
                        self.hiddenCoursesBannerHeight.constant = 20
                        self.view.layoutIfNeeded()
                    })
                }
                response = jsonData
                ta.addCoursesForOfflineMode(response: response!)
            }else{
                let alert = UIAlertController(title: "Could not reach Teachassist", message: "Please check your internet connection and try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action:UIAlertAction!) in
                    self.OnRefresh()
                }))
                self.present(alert, animated: true)
                return
            }
        }
        print(response)
        
        //add default preferences for notifications
        for i in 0...response!.count{
            let currentPreferenceExists = Preferences.object(forKey: "Course" + String(i))
            if currentPreferenceExists == nil{ //if preference does not exist
                Preferences.set(true, forKey: "Course" + String(i))
            }
        }
        Preferences.synchronize()
        
        //add courses to main view
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        for (i, course) in response!.enumerated(){
            var courseView = CourseView(frame: CGRect(x: 0, y: 0, width: 350, height: 130))
            if let mark = (course["mark"] as? CGFloat){
                courseView.ProgressBar.value = mark
            }else{
                let jsonCourse = ta.getCourseFromJson(forUsername: username!, courseNumber: i)
                    if let mark = (jsonCourse?["mark"] as? CGFloat), jsonCourse != nil{ //the comma simply adds another conditional to this statement so that the jsonCourse does not get unwrraped as a nil value
                        if((response![i]["Course_Name"] as? String) != (jsonCourse!["Course_Name"] as? String)){
                            ta.userDidLogout(forUsername: username!)
                            print("OFFLINE WIPPED")
                        }else{
                            courseView.ProgressBar.value = mark
                            courseView.hiddenCourseIndicator.isHidden = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.hiddenCoursesBanner.isHidden = false
                                self.hiddenCoursesBannerLabel.text = "One or more courses are currently hidden by your teachers."
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.hiddenCoursesBannerHeight.constant = 20
                                    self.view.layoutIfNeeded()
                                })
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.hiddenCoursesBannerHeight.constant = 0
                                    self.view.layoutIfNeeded()
                                }, completion: { (finished: Bool) in
                                    self.hiddenCoursesBanner.isHidden = true
                                })
                            }
                            
                        }
                    }else{
                        courseView.ProgressBar.isHidden = true
                        courseView.NATextView.isHidden = false
                        courseView.isUserInteractionEnabled = false
                    }
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
                }else if((course["course"]as! String).contains("FIF")){
                    courseView.CourseName.text = "French"
                }else{
                    courseView.CourseName.text = (course["Course_Name"] as! String)
                }
            }
            if(lightThemeEnabled){
                courseView.CourseName.textColor = lightThemeBlack
                courseView.CourseCode.textColor = lightThemeBlack
                courseView.PeriodNumber.textColor = lightThemeBlack
                courseView.RoomNumber.textColor = lightThemeBlack
                courseView.NATextView.textColor = lightThemeBlack
                courseView.contentView.backgroundColor = lightThemeWhite
                courseView.ProgressBar.innerRingColor = lightThemeGreen
                courseView.ProgressBar.outerRingColor = lightThemeLightBlack
                courseView.ProgressBar.fontColor = lightThemeBlack
                courseView.contentView.layer.borderColor = lightThemeLightBlack.cgColor
                courseView.ForwardButton.setImage(UIImage(named: "forward-dark"), for: .normal)
            }
            
            StackView.addArrangedSubview(courseView as UIView)
            
            courseView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
            courseList.append(courseView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnCourseSelected))
            courseView.addGestureRecognizer(tapGesture)
            
            StackViewHeight.constant = StackViewHeight.constant + 140
            if(ta.getAssignmentsFromJson(forUsername: username!, forCourse: i) == nil){
                if((response![i]["mark"]) as? String != "NA" && (response![i]["subject_id"]) as? String != "NA"){ //this is to minimize network requests for the offline mode code block which tries to check every course that isint saved even when it is NA
                    if let assignmentResp = ta.GetMarks(subjectNumber: i), assignmentResp.count > 1{
                        ta.saveAssignmentsToJson(username: username!, courseNumber: i, response: assignmentResp)
                    }
                }
            }
            
        }
        ta.saveCoursesToJson(username: username!, response: response)
        
        
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
    
    public func showReleaseNotes(){
        let Preferences = UserDefaults.standard
        Preferences.set("true", forKey: "release notes 2.2.8")
        let title = "A message from the developers"
        let message = """
            Unfortunately, we've decided that the next step in improving our app is to show banner ads. It's a sad day in the history of Teachassist.
            \n On the bright side, we wanted to soften the blow with a couple of new features: offline mode, and a statistics view. We also have a couple of other features that should arrive in the near future.
            \n But for those of you who can't stand this development, we've included an option to remove all ads for $2.79.
            \n Please accept our condolences, and we hope you enjoy :)
            """
        let image = UIImage(named: "adUpdateBanner")
        let popup = PopupDialog(title: title, message: message, image: image)
        let buttonOne = PopupDialogButton(title: "Dismiss", dismissOnTap: true) {
            print("What a beauty!")
        }
        let buttonTwo = PopupDialogButton(title: "Upgrade!", dismissOnTap: true) {
            if let drawerController = (self.navigationController?.parent as? KYDrawerController) {
                drawerController.setDrawerState(.closed, animated: true)
                (drawerController.mainViewController as! UINavigationController).viewControllers[0].performSegue(withIdentifier: "settingsSegue", sender: nil)
            }
        }
        popup.addButtons([buttonOne, buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    func loadBannerAd() {
        // Step 2 - Determine the view width to use for the ad width.
        let frame = { () -> CGRect in
            // Here safe area is taken into account, hence the view frame is used
            // after the view has been laid out.
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        let viewWidth = frame.size.width
        
        // Step 3 - Get Adaptive GADAdSize and set the ad view.
        // Here the current interface orientation is used. If the ad is being preloaded
        // for a future orientation change or different orientation, the function for the
        // relevant orientation should be used.
        adView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        // Step 4 - Create an ad request and load the adaptive banner ad.
        adView.load(GADRequest())
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PageViewControllerContainer{
            let vc = segue.destination as? PageViewControllerContainer
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
            NSAttributedString.Key.foregroundColor: lightThemeBlack],
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
        StackViewHeight.constant -= 135
        
        
        
        
    }
    
    @objc func OnRefresh() {
        var courseNumber = 0
            for view in self.StackView.arrangedSubviews{
                if courseNumber >= 0{
                    view.isHidden = true
                    view.removeFromSuperview()
                    self.StackViewHeight.constant -= 140
                }
                courseNumber += 1
            }
        self.hasViewStarted = false
        self.hiddenCoursesBanner.isHidden = true
        self.hiddenCoursesBannerHeight.constant = 0
        self.StackView.layoutIfNeeded()
        self.viewDidAppear(false)
        
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
        performSegue(withIdentifier: "PVCContainerSegue", sender: [response![courseNumber]["mark"], Double(courseNumber+numberOfRemovedCourses), response![courseNumber]["course"]])
    }
    
    
}


extension UINavigationController {   open override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
}}

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



