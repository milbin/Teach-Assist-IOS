import UIKit
import UICircularProgressRing
import HTMLEntities
import GoogleMobileAds
import SnapKit

class MarksViewController: UIViewController, UITextFieldDelegate {
    var Mark:Double? = nil
    var assignmentList = [AssignmentView]()
    var userIsEditing = false
    var courseNumber:Int? = nil
    var ta:TA? = nil
    var vcTitle:String? = nil
    var response:[String:Any]? = nil
    var originalResponse:[String:Any]? = nil
    var removedAssignments:[UIView:Int] = [:]
    var refreshControl:UIRefreshControl? = nil
    var hasViewBeenLayedOut = false
    var numOfremovedViews = 0
    var addAssignmentIsExpanded = false
    var assignmentsHaveBeenAdded = false
    
    
    var lightThemeEnabled = false
    var lightThemeLightBlack = UIColor(red: 39/255, green: 39/255, blue: 47/255, alpha: 1)
    var lightThemeWhite = UIColor(red:51/255, green:51/255, blue: 61/255, alpha:1)
    var lightThemeBlack = UIColor(red:255/255, green:255/255, blue: 255/255, alpha:1)
    var lightThemeGreen = UIColor(red: 4/255, green: 93/255, blue: 86/255, alpha: 1)
    var lightThemeBlue = UIColor(red: 255/255, green: 65/255, blue: 128/255, alpha: 1)
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var StackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AverageBar: UICircularProgressRing!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    @IBOutlet weak var MarkBarView: UIView!
    
    @IBOutlet weak var KbarAverage: UIView!
    @IBOutlet weak var KmarkAverage: UILabel!
    @IBOutlet weak var KbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var KaverageWeight: UILabel!
    @IBOutlet weak var KaverageLabel: UILabel!
    
    @IBOutlet weak var TbarAverage: UIView!
    @IBOutlet weak var TmarkAverage: UILabel!
    @IBOutlet weak var TbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var TaverageWeight: UILabel!
    @IBOutlet weak var TaverageLabel: UILabel!
    
    @IBOutlet weak var CbarAverage: UIView!
    @IBOutlet weak var CmarkAverage: UILabel!
    @IBOutlet weak var CbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var CaverageWeight: UILabel!
    @IBOutlet weak var CaverageLabel: UILabel!
    
    @IBOutlet weak var AbarAverage: UIView!
    @IBOutlet weak var AmarkAverage: UILabel!
    @IBOutlet weak var AbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var AaverageWeight: UILabel!
    @IBOutlet weak var AaverageLabel: UILabel!
    
    @IBOutlet weak var ObarAverage: UIView!
    @IBOutlet weak var OmarkAverage: UILabel!
    @IBOutlet weak var ObarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var OaverageWeight: UILabel!
    @IBOutlet weak var OaverageLabel: UILabel!
    
    @IBOutlet weak var addAssignment: UIView!
    @IBOutlet weak var AddAssignmentHeight: NSLayoutConstraint!
    @IBOutlet weak var addAssignmentBoxTitleAlignTop: NSLayoutConstraint!
    @IBOutlet weak var addAssignmentPlusButton: UIImageView!
    @IBOutlet weak var addAssignmentTitle: UITextField!
    @IBOutlet weak var addAssignmentTitleLabel: UILabel!
    @IBOutlet weak var addAssignmentSimpleMark: UITextField!
    @IBOutlet weak var addAssignmentSimpleWeight: UITextField!
    @IBOutlet weak var addAssignmentMarkLabel: UILabel!
    @IBOutlet weak var addAssignmentCancelButton: UIButton!
    @IBOutlet weak var addAssignmentAddButton: UIButton!
    
    @IBOutlet weak var addAssignmentDividerLine: UIView!
    @IBOutlet weak var addAssignmentAdvancedButton: UIButton!
    @IBOutlet weak var addAssignmentAdvancedButtonLabel: UIButton!
    @IBOutlet weak var addAssignmentKLabel: UILabel!
    @IBOutlet weak var addAssignmentTLabel: UILabel!
    @IBOutlet weak var addAssignmentCLabel: UILabel!
    @IBOutlet weak var addAssignmentALabel: UILabel!
    @IBOutlet weak var addAssignmentOLabel: UILabel!
    
    @IBOutlet weak var addAssignmentKMark: UITextField!
    @IBOutlet weak var addAssignmentTMark: UITextField!
    @IBOutlet weak var addAssignmentCMark: UITextField!
    @IBOutlet weak var addAssignmentAMark: UITextField!
    @IBOutlet weak var addAssignmentOMark: UITextField!
    @IBOutlet weak var addAssignmentKWeight: UITextField!
    @IBOutlet weak var addAssignmentTWeight: UITextField!
    @IBOutlet weak var addAssignmentCWeight: UITextField!
    @IBOutlet weak var addAssignmentAWeight: UITextField!
    @IBOutlet weak var addAssignmentOWeight: UITextField!
    
    @IBOutlet weak var topAdView: GADBannerView!
    @IBOutlet weak var topAdViewContainer: UIView!
    @IBOutlet weak var topAdLoadingLabel: UILabel!
    @IBOutlet weak var bottomAdView: GADBannerView!
    @IBOutlet weak var bottomAdViewContainer: UIView!
    @IBOutlet weak var bottomAdLoadingLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:lightThemeBlack]
        self.parent?.parent?.navigationController?.navigationBar.titleTextAttributes = textAttributes
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
                
                self.parent?.parent?.navigationController?.navigationBar.barTintColor = UIColor.white
                let textAttributes = [NSAttributedString.Key.foregroundColor:lightThemeBlack]
                self.parent?.parent?.navigationController?.navigationBar.titleTextAttributes = textAttributes
                self.AverageBar.outerRingColor = lightThemeLightBlack
                self.AverageBar.innerRingColor = lightThemeBlue
                self.AverageBar.superview?.backgroundColor = lightThemeWhite
                KbarAverage.backgroundColor = lightThemeGreen
                TbarAverage.backgroundColor = lightThemeGreen
                CbarAverage.backgroundColor = lightThemeGreen
                AbarAverage.backgroundColor = lightThemeGreen
                ObarAverage.backgroundColor = lightThemeGreen
                addAssignmentKLabel.textColor = lightThemeBlack
                addAssignmentTLabel.textColor = lightThemeBlack
                addAssignmentCLabel.textColor = lightThemeBlack
                addAssignmentALabel.textColor = lightThemeBlack
                addAssignmentOLabel.textColor = lightThemeBlack
                addAssignmentTitle.textColor = lightThemeBlack
                addAssignmentSimpleMark.textColor = lightThemeBlack
                addAssignmentSimpleWeight.textColor = lightThemeBlack
                addAssignmentMarkLabel.textColor = lightThemeBlack
                addAssignmentTitleLabel.textColor = lightThemeBlack
                addAssignmentAdvancedButtonLabel.tintColor = lightThemeBlack
                addAssignmentAdvancedButton.setImage(UIImage(named: "down-dark"), for: .normal)
                addAssignmentAdvancedButton.setImage(UIImage(named: "up-dark"), for: .selected)
                addAssignmentPlusButton.image = UIImage(named: "plus-dark")
                addAssignmentAddButton.backgroundColor = lightThemeGreen
                addAssignmentAddButton.tintColor = lightThemeBlack //for the text
                
                addAssignmentTitle.backgroundColor = lightThemeLightBlack
                addAssignmentTitle.textColor = lightThemeBlack
                addAssignmentSimpleMark.backgroundColor = lightThemeLightBlack
                addAssignmentSimpleMark.textColor = lightThemeBlack
                addAssignmentSimpleWeight.backgroundColor = lightThemeLightBlack
                addAssignmentSimpleWeight.textColor = lightThemeBlack
                
                addAssignmentKMark.backgroundColor = lightThemeLightBlack
                addAssignmentTMark.backgroundColor = lightThemeLightBlack
                addAssignmentCMark.backgroundColor = lightThemeLightBlack
                addAssignmentAMark.backgroundColor = lightThemeLightBlack
                addAssignmentOMark.backgroundColor = lightThemeLightBlack
                addAssignmentKMark.textColor = lightThemeBlack
                addAssignmentTMark.textColor = lightThemeBlack
                addAssignmentCMark.textColor = lightThemeBlack
                addAssignmentAMark.textColor = lightThemeBlack
                addAssignmentOMark.textColor = lightThemeBlack
                addAssignmentOWeight.backgroundColor = lightThemeLightBlack
                addAssignmentKWeight.backgroundColor = lightThemeLightBlack
                addAssignmentTWeight.backgroundColor = lightThemeLightBlack
                addAssignmentCWeight.backgroundColor = lightThemeLightBlack
                addAssignmentAWeight.backgroundColor = lightThemeLightBlack
                addAssignmentOWeight.textColor = lightThemeBlack
                addAssignmentKWeight.textColor = lightThemeBlack
                addAssignmentTWeight.textColor = lightThemeBlack
                addAssignmentCWeight.textColor = lightThemeBlack
                addAssignmentAWeight.textColor = lightThemeBlack
            }
        }
        //setup background color and navigation bar
        StackView.addBackground(color: lightThemeWhite)
        self.view.backgroundColor = lightThemeWhite
        scrollView.backgroundColor = lightThemeWhite
        AverageBar.font = UIFont(name: "Gilroy-Bold", size: 25)!
        AverageBar.fontColor = lightThemeBlack
        AverageBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        parent?.parent!.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(OnEditButtonPress))//add edit button as the onClick method
        parent?.parent!.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Gilroy-Regular", size: 17)!,
            NSAttributedString.Key.foregroundColor: lightThemeBlack],
                                                                  for: .normal)
        //setup mark bar height
        KbarAverageHeight.constant = 40
        TbarAverageHeight.constant = 40
        CbarAverageHeight.constant = 40
        AbarAverageHeight.constant = 40
        ObarAverageHeight.constant = 40
        
        //setup add assignment including light mode for it
        addAssignment.layer.borderWidth = 2
        addAssignment.layer.borderColor = lightThemeLightBlack.cgColor
        addAssignment.backgroundColor = lightThemeWhite
        addAssignment.layer.cornerRadius = 15
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnAddAssignmentButtonPress))
        addAssignment.addGestureRecognizer(tapGesture)
        addAssignmentTitle.attributedPlaceholder = NSAttributedString(string:"Assignment Title", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite]) //to make the colour of the placeholder gray
        addAssignmentSimpleMark.attributedPlaceholder = NSAttributedString(string:"Mark", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentSimpleWeight.attributedPlaceholder = NSAttributedString(string:"Weight", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentKMark.attributedPlaceholder = NSAttributedString(string:"Mark", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentKWeight.attributedPlaceholder = NSAttributedString(string:"Weight", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentTMark.attributedPlaceholder = NSAttributedString(string:"Mark", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentTWeight.attributedPlaceholder = NSAttributedString(string:"Weight", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentCMark.attributedPlaceholder = NSAttributedString(string:"Mark", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentCWeight.attributedPlaceholder = NSAttributedString(string:"Weight", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentAMark.attributedPlaceholder = NSAttributedString(string:"Mark", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentAWeight.attributedPlaceholder = NSAttributedString(string:"Weight", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentOMark.attributedPlaceholder = NSAttributedString(string:"Mark", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentOWeight.attributedPlaceholder = NSAttributedString(string:"Weight", attributes: [NSAttributedString.Key.foregroundColor: lightThemeWhite])
        addAssignmentTitle.delegate = self
        addAssignmentSimpleMark.addDoneCancelToolbar()
        addAssignmentSimpleWeight.addDoneCancelToolbar()
        addAssignmentCancelButton.addTarget(self, action: #selector(OnAddAssignmentCancelButtonPress), for: .touchUpInside)
        addAssignmentAddButton.addTarget(self, action: #selector(OnAddAssignmentAddButtonPress), for: .touchUpInside)
        addAssignmentCancelButton.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 5)
        addAssignmentAddButton.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 5)
        addAssignmentAdvancedButton.addTarget(self, action: #selector(OnAddAssignmentAdvancedButtonPress), for: .touchUpInside)
        addAssignmentAdvancedButtonLabel.addTarget(self, action: #selector(OnAddAssignmentAdvancedButtonPress), for: .touchUpInside)
        if(UIDevice.modelName == "iPhone 5" || UIDevice.modelName == "iPhone 5s" || UIDevice.modelName == "iPhone 5c" ||
            UIDevice.modelName == "iPod Touch 5" || UIDevice.modelName == "iPod Touch 6" || UIDevice.modelName == "iPod5,1" ||
            UIDevice.modelName == "iPod7,1" || UIDevice.modelName == "iPhone SE"){
            addAssignmentKLabel.text = "K"
            addAssignmentTLabel.text = "T"
            addAssignmentCLabel.text = "C"
            addAssignmentALabel.text = "A"
            addAssignmentOLabel.text = "O"
            
        }
        
        if vcTitle != nil{
            self.parent?.parent!.navigationItem.title = vcTitle!
        }
        
        //setup ad views if the user is not pro
        if (Preferences.object(forKey: "isProUser") as? Bool) != true{
            //setup admob ad views
            topAdView.superview!.layer.borderWidth = 2
            topAdView.superview!.layer.borderColor = lightThemeLightBlack.cgColor
            topAdView.superview!.layer.cornerRadius = 10
            topAdLoadingLabel.textColor = lightThemeBlack
            
            bottomAdView.superview!.layer.borderWidth = 2
            bottomAdView.superview!.layer.borderColor = lightThemeLightBlack.cgColor
            bottomAdView.superview!.layer.cornerRadius = 10
            bottomAdLoadingLabel.textColor = lightThemeBlack
            
            //topAdView.adUnitID = "ca-app-pub-6294253616632635/1695791404"
            topAdView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
            topAdView.rootViewController = self
            topAdView.load(GADRequest())
            
            //bottomAdView.adUnitID = "ca-app-pub-6294253616632635/1695791404"
            bottomAdView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
            bottomAdView.rootViewController = self //bottom ad view is loaded later depending on number of assignments
        }else{
            topAdViewContainer.removeFromSuperview()
            topAdView.removeFromSuperview()
            bottomAdViewContainer.removeFromSuperview()
            bottomAdView.removeFromSuperview()
        }
        
        
        scrollView.snp.makeConstraints { (make) -> Void in
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing).offset(50)
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        response = ta!.GetMarks(subjectNumber: courseNumber!)
        let Preferences = UserDefaults.standard
        let username = Preferences.string(forKey: "username")
        //print(response)
        if(response == nil || (response?.count)! < 2){
            if let offlineResp = ta!.getAssignmentsFromJson(forUsername: username!, forCourse: courseNumber!){
                response = offlineResp
            }else{
                let alert = UIAlertController(title: "Could not reach Teachassist", message: "Please check your internet connection and try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action:UIAlertAction!) in
                    self.OnRefresh()
                }))
                alert.addAction(UIAlertAction(title: "Back", style: .default, handler: { (action:UIAlertAction!) in
                    _ = self.parent?.parent!.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
                return
            }
        }
        originalResponse = response!
        (parent as! CourseInfoPageViewController).response = response
        
        ta!.saveAssignmentsToJson(username: username!, courseNumber: courseNumber!, response: response)
        //setup refresh controller to allow main view to be refreshed
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self,
                                  action: #selector(OnRefresh),
                                  for: .valueChanged)
        scrollView.refreshControl = refreshControl
        UpdateMarkBars()
        
        
        for i in 0...(response!.count - 2){
            var assignmentWithFeedbackAndTitle = response![String(i)]! as! [String:Any]
            var title = (assignmentWithFeedbackAndTitle["title"]! as! String).htmlUnescape()
            var feedback = (assignmentWithFeedbackAndTitle["feedback"] as? String)
            if feedback == nil{
                feedback = ""
            }else{
                feedback = feedback!.htmlUnescape().replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
            }
            assignmentWithFeedbackAndTitle.removeValue(forKey: "title")
            assignmentWithFeedbackAndTitle.removeValue(forKey: "feedback")
            for category in assignmentWithFeedbackAndTitle{
                var value = (category.value as! [String:String?])
                if value["mark"] == nil{
                    assignmentWithFeedbackAndTitle[category.key] = nil
                }else if value["outOf"] == nil{
                    assignmentWithFeedbackAndTitle[category.key] = nil
                }else if value["weight"] == nil{
                    assignmentWithFeedbackAndTitle[category.key] = nil
                }else if (value as? [String:String]) == nil{
                    assignmentWithFeedbackAndTitle[category.key] = nil
                }else{
                    assignmentWithFeedbackAndTitle[category.key] = value as! [String:String]
                }
            }
            var assignment = assignmentWithFeedbackAndTitle as! [String:[String:String]]
            if(!assignmentsHaveBeenAdded){ //to resolve the bug where assignemnts get added twice because the system calls this method when the user swips back
                addAssignmentToStackview(assignment: assignment, feedback: feedback, title: title)
            }
        }
        
        //only show bottom ad view if it is there are 5 or more assignments present and the use is not pro
        if (Preferences.object(forKey: "isProUser") as? Bool) != true{
            if(assignmentList.count < 5){
                bottomAdViewContainer.removeFromSuperview()
                bottomAdView.removeFromSuperview()
            }else{
                bottomAdView.load(GADRequest())
            }
        }
        AverageBar.startProgress(to: CGFloat(Mark!), duration: 1.8)
        addAssignment.isHidden = false
        
        if refreshControl!.isRefreshing{
            refreshControl!.endRefreshing()
        }
        if(!assignmentsHaveBeenAdded){
            assignmentsHaveBeenAdded = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        if hasViewBeenLayedOut == false && response != nil{
            hasViewBeenLayedOut = true
            
            for assignment in StackView.arrangedSubviews{
                assignment.invalidateIntrinsicContentSize()
                assignment.layoutMargins.top = 5
                assignment.layoutMargins.bottom = 5
            }
        }
        
        
    }
    
    @objc func OnEditButtonPress(sender: UIBarButtonItem){
        print("edit Button pressed")
        
        if userIsEditing{
            userIsEditing = false
            for assignment in assignmentList{
                assignment.TrashButton.isHidden = true
            }
        }else{
            userIsEditing = true
            for assignment in assignmentList{
                assignment.TrashButton.isHidden = false
            }
        }
    }
    
    @objc func OnTrashButtonPress(sender: UIButton) {
        print("Pressed Trash Button")
        let view = sender.superview?.superview
        
        response![String(removedAssignments[view!]!)] = nil
        AverageBar.value = CGFloat(ta!.CalculateCourseAverage(markParam: response!))
        view?.isHidden = true
        view?.removeFromSuperview()
        UpdateMarkBars()
        
        StackViewHeight.constant -= 135
        
    }
    @objc func OnAddAssignmentButtonPress(gesture: UIGestureRecognizer) {
        if(!self.addAssignmentAdvancedButton.isSelected){
            UIView.animate(withDuration: 0.1, animations: {
                self.AddAssignmentHeight.constant = 325 //should be 135 when inactive, 325 when not in advanced, 550 when in advanced
                self.addAssignmentBoxTitleAlignTop.isActive = true
                self.addAssignmentPlusButton.isHidden = true
                self.addAssignmentTitle.isHidden = false
                self.addAssignmentSimpleMark.isHidden = false
                self.addAssignmentSimpleWeight.isHidden = false
                self.addAssignmentMarkLabel.isHidden = false
                self.addAssignmentCancelButton.isHidden = false
                self.addAssignmentAddButton.isHidden = false
                self.addAssignmentAdvancedButton.isHidden = false
                self.addAssignmentAdvancedButtonLabel.isHidden = false
                self.addAssignmentDividerLine.isHidden = false
            })
            addAssignmentIsExpanded = true
        }
    }
    @objc func OnAddAssignmentAddButtonPress(sender: UIButton) {
        let title = addAssignmentTitle.text
        if(title == nil || title == ""){
            let alert = UIAlertController(title: "Error Adding Assignment", message: "Please enter a title for this assignment", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
            return
        }
        var dict = [String : [String : String]]()
        if(self.addAssignmentAdvancedButton.isSelected){ //advanced mode
            let markK = Double(addAssignmentKMark.text!) ?? 0.93741
            let markT = Double(addAssignmentTMark.text!) ?? 0.93741
            let markC = Double(addAssignmentCMark.text!) ?? 0.93741
            let markA = Double(addAssignmentAMark.text!) ?? 0.93741
            let markO = Double(addAssignmentOMark.text!) ?? 0.93741
            let weightK = Double(addAssignmentKWeight.text!) ?? 0.0
            let weightT = Double(addAssignmentTWeight.text!) ?? 0.0
            let weightC = Double(addAssignmentCWeight.text!) ?? 0.0
            let weightA = Double(addAssignmentAWeight.text!) ?? 0.0
            let weightO = Double(addAssignmentOWeight.text!) ?? 0.0
            if(markK < 0 || markT < 0 || markC < 0 || markA < 0 || markO < 0 || weightK < 0 || weightT < 0 || weightC < 0 || weightA < 0 || weightO < 0){
                let alert = UIAlertController(title: "Error Adding Assignment", message: "Please enter a number for mark and weight that is greater than or equal to zero", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                return
            }else if(markK == 0.93741 && markT == 0.93741 && markC == 0.93741 && markA == 0.93741 && markO == 0.93741){
                let alert = UIAlertController(title: "Error Adding Assignment", message: "Please enter at least one mark. Avoid using letters or percent symbols.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                return
            }else if(markK > 150 || markT > 150 || markC > 150 || markA > 150 || markO > 150){
                let alert = UIAlertController(title: "Error, Mark Too High", message: "Please enter a mark less than 150%", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                return
            }else{
                if(markK != 0.93741){
                    dict["K"] = ["category" : "K",
                                 "mark" : String(markK),
                                 "outOf" : "100",
                                 "weight" : String(weightK)]
                }
                if(markT != 0.93741){
                    dict["T"] = ["category" : "T",
                                 "mark" : String(markT),
                                 "outOf" : "100",
                                 "weight" : String(weightT)]
                }
                if(markC != 0.93741){
                    dict["C"] = ["category" : "C",
                                 "mark" : String(markC),
                                 "outOf" : "100",
                                 "weight" : String(weightC)]
                }
                if(markA != 0.93741){
                    dict["A"] = ["category" : "A",
                                 "mark" : String(markA),
                                 "outOf" : "100",
                                 "weight" : String(weightA)]
                }
                if(markO != 0.93741){
                    dict[""] = ["category" : "",
                                "mark" : String(markO),
                                "outOf" : "100",
                                "weight" : String(weightO)]
                }
            }
        }else{ //simple mode
            var mark = Double(addAssignmentSimpleMark.text!)
            var weight = Double(addAssignmentSimpleWeight.text!)
            if(mark == nil || weight == nil){
                let alert = UIAlertController(title: "Error Adding Assignment", message: "Please enter a number for mark and weight. Avoid using any letters or percent symbols.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                return
            }else if(mark! < 0 || weight! < 0){
                let alert = UIAlertController(title: "Error Adding Assignment", message: "Please enter a number for mark and weight that is greater than or equal to zero", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                return
            }else if(mark! > 150){
                let alert = UIAlertController(title: "lol yeah right", message: "no way you got a mark higher than 150%", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
                return
            }else{
                mark = round(mark! * 10)/10
                weight = round(weight! * 10)/10
                dict["K"] = ["category" : "K",
                             "mark" : String(mark!),
                             "outOf" : "100",
                             "weight" : String(weight!)]
                dict["T"] = ["category" : "T",
                             "mark" : String(mark!),
                             "outOf" : "100",
                             "weight" : String(weight!)]
                dict["C"] = ["category" : "C",
                             "mark" : String(mark!),
                             "outOf" : "100",
                             "weight" : String(weight!)]
                dict["A"] = ["category" : "A",
                             "mark" : String(mark!),
                             "outOf" : "100",
                             "weight" : String(weight!)]
                
            }
        }
        addAssignmentToStackview(assignment: dict, feedback: "", title: title)
        var dict2 = [String:Any]()
        dict2["title"] = title!
        dict2["feedback"] = ""
        dict2["K"] = dict["K"]
        dict2["T"] = dict["T"]
        dict2["C"] = dict["C"]
        dict2["A"] = dict["A"]
        dict2[""] = dict[""]
        response![String(response!.count-1)] = dict2
        
        UpdateMarkBars()
        AverageBar.value = CGFloat((ta?.CalculateCourseAverage(markParam: response!))!)
        addAssignmentIsExpanded = false
        self.addAssignmentTitle.text = nil
        self.addAssignmentSimpleMark.text = nil
        self.addAssignmentSimpleWeight.text = nil
        self.addAssignmentKMark.text = nil
        self.addAssignmentTMark.text = nil
        self.addAssignmentCMark.text = nil
        self.addAssignmentAMark.text = nil
        self.addAssignmentOMark.text = nil
        self.addAssignmentKWeight.text = nil
        self.addAssignmentTWeight.text = nil
        self.addAssignmentCWeight.text = nil
        self.addAssignmentAWeight.text = nil
        self.addAssignmentOWeight.text = nil
        self.addAssignmentAdvancedButton.isSelected = true
        OnAddAssignmentAdvancedButtonPress(sender: addAssignmentAdvancedButton)
        UIView.animate(withDuration: 0.1, animations: {
            self.AddAssignmentHeight.constant = 129
            self.addAssignmentBoxTitleAlignTop.isActive = false
            self.addAssignmentPlusButton.isHidden = false
            self.addAssignmentTitle.isHidden = true
            self.addAssignmentSimpleMark.isHidden = true
            self.addAssignmentSimpleWeight.isHidden = true
            self.addAssignmentMarkLabel.isHidden = true
            self.addAssignmentCancelButton.isHidden = true
            self.addAssignmentAddButton.isHidden = true
            self.addAssignmentAdvancedButton.isHidden = true
            self.addAssignmentAdvancedButtonLabel.isHidden = true
            self.addAssignmentDividerLine.isHidden = true
        })
        
    
        
        
    }
    @objc func OnAddAssignmentCancelButtonPress(sender: UIButton) {
        addAssignmentIsExpanded = false
        self.addAssignmentTitle.text = nil
        self.addAssignmentSimpleMark.text = nil
        self.addAssignmentSimpleWeight.text = nil
        self.addAssignmentAdvancedButton.isSelected = true
        OnAddAssignmentAdvancedButtonPress(sender: addAssignmentAdvancedButton)
        UIView.animate(withDuration: 0.1, animations: {
            self.AddAssignmentHeight.constant = 129
            self.addAssignmentBoxTitleAlignTop.isActive = false
            self.addAssignmentPlusButton.isHidden = false
            self.addAssignmentTitle.isHidden = true
            self.addAssignmentSimpleMark.isHidden = true
            self.addAssignmentSimpleWeight.isHidden = true
            self.addAssignmentMarkLabel.isHidden = true
            self.addAssignmentCancelButton.isHidden = true
            self.addAssignmentAddButton.isHidden = true
            self.addAssignmentAdvancedButton.isHidden = true
            self.addAssignmentAdvancedButtonLabel.isHidden = true
            self.addAssignmentDividerLine.isHidden = true
            
        })
    }
    @objc func OnAddAssignmentAdvancedButtonPress(sender: UIButton) {
        if(self.addAssignmentAdvancedButton.isSelected){
            self.addAssignmentAdvancedButton.isSelected = false
            self.addAssignmentSimpleMark.isEnabled = true
            self.addAssignmentSimpleMark.alpha = 1
            self.addAssignmentSimpleWeight.isEnabled = true
            self.addAssignmentSimpleWeight.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                self.AddAssignmentHeight.constant = 325
                self.addAssignmentKMark.isHidden = true
                self.addAssignmentTMark.isHidden = true
                self.addAssignmentCMark.isHidden = true
                self.addAssignmentAMark.isHidden = true
                self.addAssignmentOMark.isHidden = true
                self.addAssignmentOWeight.isHidden = true
                self.addAssignmentKWeight.isHidden = true
                self.addAssignmentTWeight.isHidden = true
                self.addAssignmentCWeight.isHidden = true
                self.addAssignmentAWeight.isHidden = true
                self.addAssignmentKLabel.isHidden = true
                self.addAssignmentTLabel.isHidden = true
                self.addAssignmentCLabel.isHidden = true
                self.addAssignmentALabel.isHidden = true
                self.addAssignmentOLabel.isHidden = true
            })
        }else{
            self.addAssignmentAdvancedButton.isSelected = true
            self.addAssignmentSimpleMark.isEnabled = false
            self.addAssignmentSimpleMark.alpha = 0.5
            self.addAssignmentSimpleMark.text = ""
            self.addAssignmentSimpleWeight.isEnabled = false
            self.addAssignmentSimpleWeight.text = ""
            self.addAssignmentSimpleWeight.alpha = 0.5
            UIView.animate(withDuration: 0.5, animations: {
                self.AddAssignmentHeight.constant = 550
                self.addAssignmentKMark.isHidden = false
                self.addAssignmentTMark.isHidden = false
                self.addAssignmentCMark.isHidden = false
                self.addAssignmentAMark.isHidden = false
                self.addAssignmentOMark.isHidden = false
                self.addAssignmentOWeight.isHidden = false
                self.addAssignmentKWeight.isHidden = false
                self.addAssignmentTWeight.isHidden = false
                self.addAssignmentCWeight.isHidden = false
                self.addAssignmentAWeight.isHidden = false
                self.addAssignmentKLabel.isHidden = false
                self.addAssignmentTLabel.isHidden = false
                self.addAssignmentCLabel.isHidden = false
                self.addAssignmentALabel.isHidden = false
                self.addAssignmentOLabel.isHidden = false
            })
        }
    }
    
    
    
    @objc func OnAssignmentSelected(gesture: UIGestureRecognizer){
        print("ASSIGNMENT SELECTED")
        let view = gesture.view! as! AssignmentView
        
        
        if view.toggleState(newHeight: 270){
            
            view.centerXConstraint.isActive = true
            view.centerAverageConstraint.isActive = true
            view.feedback.isHidden = false
            
            view.KBarHeight.constant = view.KBarHeight.constant * 1.8
            view.KBarWidth.constant = view.KBarWidth.constant * 1.8
            view.KWeight.isHidden = false
            view.KBarBottomMargin.constant = 20
            view.KFraction.isHidden = false
            
            view.TBarHeight.constant = view.TBarHeight.constant * 1.8
            view.TBarWidth.constant = view.TBarWidth.constant * 1.8
            view.TWeight.isHidden = false
            view.TBarBottomMargin.constant = 20
            view.TFraction.isHidden = false
            
            view.CBarHeight.constant = view.CBarHeight.constant * 1.8
            view.CBarWidth.constant = view.CBarWidth.constant * 1.8
            view.CWeight.isHidden = false
            view.CBarBottomMargin.constant = 20
            view.CFraction.isHidden = false
            
            view.ABarHeight.constant = view.ABarHeight.constant * 1.8
            view.ABarWidth.constant = view.ABarWidth.constant * 1.8
            view.AWeight.isHidden = false
            view.ABarBottomMargin.constant = 20
            view.AFraction.isHidden = false
            
            view.OBarHeight.constant = view.OBarHeight.constant * 1.8
            view.OBarWidth.constant = view.OBarWidth.constant * 1.8
            view.OWeight.isHidden = false
            view.OBarBottomMargin.constant = 20
            view.OFraction.isHidden = false
            
            UIView.animate(withDuration: 0.1, animations: {
                view.layoutIfNeeded()
                view.KBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.TBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.CBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.ABar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.OBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            })
            StackViewHeight.constant += 270
        }else{
            
            view.centerXConstraint.isActive = false
            view.centerAverageConstraint.isActive = false
            view.feedback.isHidden = true
            
            view.KBarHeight.constant = view.KBarHeight.constant / 1.8
            view.KBarWidth.constant = view.KBarWidth.constant / 1.8
            view.KWeight.isHidden = true
            view.KBarBottomMargin.constant = 10
            view.KFraction.isHidden = true
            
            view.TBarHeight.constant = view.TBarHeight.constant / 1.8
            view.TBarWidth.constant = view.TBarWidth.constant / 1.8
            view.TWeight.isHidden = true
            view.TBarBottomMargin.constant = 10
            view.TFraction.isHidden = true
            
            view.CBarHeight.constant = view.CBarHeight.constant / 1.8
            view.CBarWidth.constant = view.CBarWidth.constant / 1.8
            view.CWeight.isHidden = true
            view.CBarBottomMargin.constant = 10
            view.CFraction.isHidden = true
            
            view.ABarHeight.constant = view.ABarHeight.constant / 1.8
            view.ABarWidth.constant = view.ABarWidth.constant / 1.8
            view.AWeight.isHidden = true
            view.ABarBottomMargin.constant = 10
            view.AFraction.isHidden = true
            
            view.OBarHeight.constant = view.OBarHeight.constant / 1.8
            view.OBarWidth.constant = view.OBarWidth.constant / 1.8
            view.OWeight.isHidden = true
            view.OBarBottomMargin.constant = 10
            view.OFraction.isHidden = true
            
            UIView.animate(withDuration: 0.1, animations: {
                view.layoutIfNeeded()
                view.KBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.TBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.CBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.ABar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                view.OBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
                self.StackViewHeight.constant -= 270
            }, completion: {(finished: Bool) in

                
            })
            
        }
        
        
        
        
        
        
    }
    
    
    
    @objc func OnRefresh() {
        print("refreshed")
        for view in StackView.arrangedSubviews{
            view.isHidden = true
            view.removeFromSuperview()
        }
        assignmentsHaveBeenAdded = false
        StackViewHeight.constant = 0
        StackView.layoutIfNeeded()
        AverageBar.startProgress(to: 0.0, duration: 0)
        viewDidAppear(true)
        userIsEditing = false
        
        
    }
    
    func addAssignmentToStackview(assignment:[String:[String:String]], feedback:String?, title:String?){
        var assignmentView = AssignmentView(frame: CGRect(x: 0, y: 0, width: 350, height: 129))
        
        assignmentView.AssignmentTitle.text = title
        
        var markList = ["K" : 0.000000001, "T" : 0.000000001, "C" : 0.000000001, "A" : 0.000000001, "" : 0.000000001]
        var weightList = ["K" : 0.0, "T" : 0.0, "C" : 0.0, "A" : 0.0, "" : 0.0]
        var stringFractionList = ["K" : "", "T" : "", "C" : "", "A" : "", "" : ""]
        let categoryList = ["K", "T", "C", "A", ""]
        
        for category in categoryList{
            if assignment[category] != nil && assignment[category]!["mark"] != nil{
                if assignment[category]!["mark"]! == "no mark" || assignment[category]!["mark"]! == "No mark" || assignment[category]!["mark"]! == "No Mark"{
                    markList[category] = 0.0
                }
            }
        }
        for category in categoryList{
            if assignment[category] != nil{
                if assignment[category]!["weight"] != nil && assignment[category]!["weight"]! != ""{
                    weightList[category] = Double(assignment[category]!["weight"]!)
                }
                if assignment[category]!["outOf"] != nil && assignment[category]!["outOf"] != "0" && assignment[category]!["outOf"] != "0.0"{
                    if assignment[category]!["mark"] != nil && assignment[category]!["mark"] != "0.93741"{
                        markList[category] = round(10 * (Double(assignment[category]!["mark"]!)! / Double(assignment[category]!["outOf"]!)! * 100)) / 10
                    }
                }
                if (assignment[category]!["mark"] != nil && assignment[category]!["mark"]! == "") || assignment[category]!["mark"] == nil || assignment[category]!["mark"] == "0.93741"{
                    stringFractionList[category] = "0/"
                }else{
                    stringFractionList[category] = assignment[category]!["mark"]! + "/"
                }
                if (assignment[category]!["outOf"] != nil && assignment[category]!["outOf"]! == "") || assignment[category]!["outOf"] == nil || assignment[category]!["outOf"] == "0.93741"{
                    stringFractionList[category] = stringFractionList[category]! + "0"
                }else{
                    stringFractionList[category] = stringFractionList[category]! + assignment[category]!["outOf"]!
                }
            }else{
                weightList[category] = 0.0
            }
            
        }
        print(assignment)
        var average = (ta?.calculateAssignmentAverage(assignment: assignment, courseWeights: response!["categories"]! as! [String:Double], assignmentWeights: weightList))!
        ta?.didRecursivelyCallCalculateAssignmentAverage = false
        if average == "100.0"{
            average = "100"
            assignmentView.AssignmentMark.text = "100%"
        }else if average == "nan"{
            assignmentView.AssignmentMark.text = "No Mark"
        }else{
            assignmentView.AssignmentMark.text =  average + "%"
        }
        StackViewHeight.constant = StackViewHeight.constant + 135
        if(lightThemeEnabled){
            assignmentView.contentView.backgroundColor = lightThemeWhite
            assignmentView.KBar.backgroundColor = self.lightThemeGreen
            assignmentView.TBar.backgroundColor = self.lightThemeGreen
            assignmentView.CBar.backgroundColor = self.lightThemeGreen
            assignmentView.ABar.backgroundColor = self.lightThemeGreen
            assignmentView.OBar.backgroundColor = self.lightThemeGreen
            assignmentView.AssignmentMark.textColor = self.lightThemeBlack
            assignmentView.AssignmentTitle.textColor = self.lightThemeBlack
            assignmentView.KFraction.textColor = self.lightThemeBlack
            assignmentView.TFraction.textColor = self.lightThemeBlack
            assignmentView.CFraction.textColor = self.lightThemeBlack
            assignmentView.AFraction.textColor = self.lightThemeBlack
            assignmentView.OFraction.textColor = self.lightThemeBlack
            assignmentView.KMark.textColor = self.lightThemeBlack
            assignmentView.TMark.textColor = self.lightThemeBlack
            assignmentView.CMark.textColor = self.lightThemeBlack
            assignmentView.AMark.textColor = self.lightThemeBlack
            assignmentView.OMark.textColor = self.lightThemeBlack
            assignmentView.KWeight.textColor = self.lightThemeBlack
            assignmentView.TWeight.textColor = self.lightThemeBlack
            assignmentView.CWeight.textColor = self.lightThemeBlack
            assignmentView.AWeight.textColor = self.lightThemeBlack
            assignmentView.OWeight.textColor = self.lightThemeBlack
            assignmentView.feedback.textColor = self.lightThemeBlack
            assignmentView.contentView.layer.borderColor = self.lightThemeLightBlack.cgColor
        }
        StackView.addArrangedSubview(assignmentView as UIView)
        assignmentView.layoutIfNeeded()
        UIView.animate(withDuration: 1, animations: {
            if markList["K"]! == 100.0{
                assignmentView.KMark.text = "100"
                assignmentView.KBarHeight.constant = 100 * 0.55 + 15
            }else if markList["K"]! == 0.000000001{
                assignmentView.KMark.text = "NA"
                assignmentView.KBarHeight.constant = 15
                assignmentView.KBar.backgroundColor = self.lightThemeBlue //teachassist themed pink
                assignmentView.KMark.textColor = self.lightThemeWhite
            }else{
                assignmentView.KMark.text = String(markList["K"]!)
                assignmentView.KBarHeight.constant = CGFloat(markList["K"]!) * 0.55 + 15
                
            }
            
            if markList["T"]! == 100.0{
                assignmentView.TMark.text = "100"
                assignmentView.TBarHeight.constant = 100 * 0.55 + 15
            }else if markList["T"]! == 0.000000001{
                assignmentView.TMark.text = "NA"
                assignmentView.TBarHeight.constant = 15
                assignmentView.TBar.backgroundColor = self.lightThemeBlue //teachassist themed pink
                assignmentView.TMark.textColor = self.lightThemeWhite
            }else{
                assignmentView.TMark.text = String(markList["T"]!)
                assignmentView.TBarHeight.constant = CGFloat(markList["T"]!) * 0.55 + 15
            }
            
            if markList["C"]! == 100.0{
                assignmentView.CMark.text = "100"
                assignmentView.CBarHeight.constant = 100 * 0.55 + 15
            }else if markList["C"]! == 0.000000001{
                assignmentView.CMark.text = "NA"
                assignmentView.CBarHeight.constant = 15
                assignmentView.CBar.backgroundColor = self.lightThemeBlue //teachassist themed pink
                assignmentView.CMark.textColor = self.lightThemeWhite
            }else{
                assignmentView.CMark.text = String(markList["C"]!)
                assignmentView.CBarHeight.constant = CGFloat(markList["C"]!) * 0.55 + 15
            }
            
            if markList["A"]! == 100.0{
                assignmentView.AMark.text = "100"
                assignmentView.ABarHeight.constant = 100 * 0.55 + 15
            }else if markList["A"]! == 0.000000001{
                assignmentView.AMark.text = "NA"
                assignmentView.ABarHeight.constant = 15
                assignmentView.ABar.backgroundColor = self.lightThemeBlue //teachassist themed pink
                assignmentView.AMark.textColor = self.lightThemeWhite
            }else{
                assignmentView.AMark.text = String(markList["A"]!)
                assignmentView.ABarHeight.constant = CGFloat(markList["A"]!) * 0.55 + 15
            }
            
            if markList[""]! == 100.0{
                assignmentView.OMark.text = "100"
                assignmentView.OBarHeight.constant = 100 * 0.55 + 15
            }else if markList[""]! == 0.000000001{
                assignmentView.OMark.text = "NA"
                assignmentView.OBarHeight.constant = 15
                assignmentView.OBar.backgroundColor = self.lightThemeBlue //teachassist themed pink
                assignmentView.OMark.textColor = self.lightThemeWhite
            }else{
                assignmentView.OMark.text = String(markList[""]!)
                assignmentView.OBarHeight.constant = CGFloat(markList[""]!) * 0.55 + 15
            }
            
            assignmentView.layoutIfNeeded()
        })
        
        assignmentView.KWeight.text = String(weightList["K"]!)
        assignmentView.TWeight.text = String(weightList["T"]!)
        assignmentView.CWeight.text = String(weightList["C"]!)
        assignmentView.AWeight.text = String(weightList["A"]!)
        assignmentView.OWeight.text = String(weightList[""]!)
        
        assignmentView.KLabel.textColor = lightThemeBlack
        assignmentView.TLabel.textColor = lightThemeBlack
        assignmentView.CLabel.textColor = lightThemeBlack
        assignmentView.ALabel.textColor = lightThemeBlack
        assignmentView.OLabel.textColor = lightThemeBlack
        
        assignmentView.KFraction.text = stringFractionList["K"]
        assignmentView.TFraction.text = stringFractionList["T"]
        assignmentView.CFraction.text = stringFractionList["C"]
        assignmentView.AFraction.text = stringFractionList["A"]
        assignmentView.OFraction.text = stringFractionList["O"]
        
        assignmentView.KBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        assignmentView.TBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        assignmentView.CBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        assignmentView.ABar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        assignmentView.OBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        
        if(feedback == ""){
            assignmentView.feedback.text = "No Feedback"
            assignmentView.feedback.textAlignment = .center
        }else{
            assignmentView.feedback.text = "Feedback: \n" + feedback!
        }
        
        assignmentView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
        assignmentList.append(assignmentView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnAssignmentSelected))
        assignmentView.addGestureRecognizer(tapGesture)
        
        var assignmentNumber = 0
        for assignment in StackView.arrangedSubviews{
            removedAssignments[assignment] = assignmentNumber
            assignmentNumber += 1
        }
        
    }
    
    func UpdateMarkBars(){
        let list = ta!.GetCategoryAndWeightsForCourse(marks: response!)
        
        KbarAverageHeight.constant = CGFloat(list[0] * 0.9 + 35)
        TbarAverageHeight.constant = CGFloat(list[1] * 0.9 + 35)
        CbarAverageHeight.constant = CGFloat(list[2] * 0.9 + 35)
        AbarAverageHeight.constant = CGFloat(list[3] * 0.9 + 35)
        ObarAverageHeight.constant = CGFloat(list[4] * 0.9 + 35)
        
            
        KbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        TbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        CbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        AbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        ObarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        
        if list[0] != 0{
            KmarkAverage.text = String(round(list[0]*1000)/1000)
            KbarAverage.backgroundColor = lightThemeGreen
            KmarkAverage.textColor = lightThemeBlack
            KaverageLabel.textColor = lightThemeBlack
        }else{
            KmarkAverage.text = "NA"
            KbarAverage.backgroundColor = lightThemeBlue
        }
        
        if list[1] != 0{
            TmarkAverage.text = String(round(list[1]*1000)/1000)
            TbarAverage.backgroundColor = lightThemeGreen
            TmarkAverage.textColor = lightThemeBlack
            TaverageLabel.textColor = lightThemeBlack
        }else{
            TmarkAverage.text = "NA"
            TbarAverage.backgroundColor = lightThemeBlue
        }
        
        if list[2] != 0{
            CmarkAverage.text = String(round(list[2]*1000)/1000)
            CbarAverage.backgroundColor = lightThemeGreen
            CmarkAverage.textColor = lightThemeBlack
            CaverageLabel.textColor = lightThemeBlack
        }else{
            CmarkAverage.text = "NA"
            CbarAverage.backgroundColor = lightThemeBlue
        }
        
        if list[3] != 0{
            AmarkAverage.text = String(round(list[3]*1000)/1000)
            AbarAverage.backgroundColor = lightThemeGreen
            AmarkAverage.textColor = lightThemeBlack
            AaverageLabel.textColor = lightThemeBlack
        }else{
            AmarkAverage.text = "NA"
            AbarAverage.backgroundColor = lightThemeBlue
        }
        
        if list[4] != 0{
            OmarkAverage.text = String(round(list[4]*1000)/1000)
            ObarAverage.backgroundColor = lightThemeGreen
            OmarkAverage.textColor = lightThemeBlack
            OaverageLabel.textColor = lightThemeBlack
        }else{
            OmarkAverage.text = "NA"
            ObarAverage.backgroundColor = lightThemeBlue
        }
        
        
        KaverageWeight.text = String(list[5])
        TaverageWeight.text = String(list[6])
        CaverageWeight.text = String(list[7])
        AaverageWeight.text = String(list[8])
        OaverageWeight.text = String(list[9])
        KaverageWeight.textColor = lightThemeBlack
        TaverageWeight.textColor = lightThemeBlack
        CaverageWeight.textColor = lightThemeBlack
        AaverageWeight.textColor = lightThemeBlack
        OaverageWeight.textColor = lightThemeBlack
        
        UIView.animate(withDuration: 0.1, animations: {
            self.MarkBarView.layoutIfNeeded()
            self.KbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.TbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.CbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.AbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.ObarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        })
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    
    
    
    
    
    
    
}

extension UIStackView { //only way to have a non transparent stackview
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    func cancelButtonTapped() { self.resignFirstResponder() }
}
