import UIKit
import UICircularProgressRing
import HTMLEntities

class MarksViewController: UIViewController {
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
    
    @IBOutlet weak var TbarAverage: UIView!
    @IBOutlet weak var TmarkAverage: UILabel!
    @IBOutlet weak var TbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var TaverageWeight: UILabel!
    
    @IBOutlet weak var CbarAverage: UIView!
    @IBOutlet weak var CmarkAverage: UILabel!
    @IBOutlet weak var CbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var CaverageWeight: UILabel!
    
    @IBOutlet weak var AbarAverage: UIView!
    @IBOutlet weak var AmarkAverage: UILabel!
    @IBOutlet weak var AbarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var AaverageWeight: UILabel!
    
    @IBOutlet weak var ObarAverage: UIView!
    @IBOutlet weak var OmarkAverage: UILabel!
    @IBOutlet weak var ObarAverageHeight: NSLayoutConstraint!
    @IBOutlet weak var OaverageWeight: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MARKS VIEW")
        AverageBar.font = UIFont(name: "Gilroy-Bold", size: 25)!
        AverageBar.fontColor = UIColor.white
        AverageBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(OnEditButtonPress))//add edit button as the onClick method
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        if vcTitle != nil{
            self.title = vcTitle!
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        response = ta!.GetMarks(subjectNumber: courseNumber!)
        if response == nil{
            let alert = UIAlertController(title: "Error: Could not reach Teachassist", message: "Please check your internet connection and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action:UIAlertAction!) in
                self.OnRefresh()
            }))
            alert.addAction(UIAlertAction(title: "Back", style: .default, handler: { (action:UIAlertAction!) in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true)
            return
        }
        originalResponse = response!
        
        print(response)
        
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
                        if assignment[category]!["mark"] != nil{
                            markList[category] = round(10 * (Double(assignment[category]!["mark"]!)! / Double(assignment[category]!["outOf"]!)! * 100)) / 10
                        }
                    }
                    if (assignment[category]!["mark"] != nil && assignment[category]!["mark"]! == "") || assignment[category]!["mark"] == nil{
                        stringFractionList[category] = "0/"
                    }else{
                        stringFractionList[category] = assignment[category]!["mark"]! + "/"
                    }
                    if (assignment[category]!["outOf"] != nil && assignment[category]!["outOf"]! == "") || assignment[category]!["outOf"] == nil{
                        stringFractionList[category] = stringFractionList[category]! + "0"
                    }else{
                        stringFractionList[category] = stringFractionList[category]! + assignment[category]!["outOf"]!
                    }
                }else{
                    weightList[category] = 0.0
                }
                
            }
            print(assignment)
            var average = (ta?.calculateAssignmentAverage(assignment: assignment, weights: response!["categories"]! as! [String:Double]))!
            if average == "100.0"{
                average = "100"
                assignmentView.AssignmentMark.text = "100%"
            }else if average == "nan"{
                assignmentView.AssignmentMark.text = "No Mark"
            }else{
                assignmentView.AssignmentMark.text =  average + "%"
            }
            StackViewHeight.constant = StackViewHeight.constant + 139
            StackView.addArrangedSubview(assignmentView as UIView)
            assignmentView.layoutIfNeeded()
            UIView.animate(withDuration: 1, animations: {
                if markList["K"]! == 100.0{
                    assignmentView.KMark.text = "100"
                    assignmentView.KBarHeight.constant = 100 * 0.55 + 15
                }else if markList["K"]! == 0.000000001{
                    assignmentView.KMark.text = "NA"
                    assignmentView.KBarHeight.constant = 15
                    assignmentView.KBar.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
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
                    assignmentView.TBar.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
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
                    assignmentView.CBar.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
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
                    assignmentView.ABar.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
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
                    assignmentView.OBar.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
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
            
            assignmentView.feedback.text = "feedback: " + feedback!
            assignmentView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
            assignmentList.append(assignmentView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnAssignmentSelected))
            assignmentView.addGestureRecognizer(tapGesture)
            
            
            
            
        }
        AverageBar.startProgress(to: CGFloat(Mark!), duration: 1.8)
        var assignmentNumber = 0
        for assignment in StackView.arrangedSubviews{
            removedAssignments[assignment] = assignmentNumber
            assignmentNumber += 1
        }
        
        if refreshControl!.isRefreshing{
            refreshControl!.endRefreshing()
        }
    }
    
    override func viewDidLayoutSubviews() {
        if hasViewBeenLayedOut == false && response != nil{
            hasViewBeenLayedOut = true
            StackView.addBackground(color: UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0))
            
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
        
        StackViewHeight.constant -= 139
        
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
        StackViewHeight.constant = 0
        StackView.layoutIfNeeded()
        AverageBar.startProgress(to: 0.0, duration: 0)
        viewDidAppear(true)
        userIsEditing = false
        
        
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
            KbarAverage.backgroundColor = UIColor(red:04/255, green:93/255, blue:86/255, alpha:1.0)
        }else{
            KmarkAverage.text = "NA"
            KbarAverage.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0)
        }
        
        if list[1] != 0{
            TmarkAverage.text = String(round(list[1]*1000)/1000)
            TbarAverage.backgroundColor = UIColor(red:04/255, green:93/255, blue:86/255, alpha:1.0)
        }else{
            TmarkAverage.text = "NA"
            TbarAverage.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0)
        }
        
        if list[2] != 0{
            CmarkAverage.text = String(round(list[2]*1000)/1000)
            CbarAverage.backgroundColor = UIColor(red:04/255, green:93/255, blue:86/255, alpha:1.0)
        }else{
            CmarkAverage.text = "NA"
            CbarAverage.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0)
        }
        
        if list[3] != 0{
            AmarkAverage.text = String(round(list[3]*1000)/1000)
            AbarAverage.backgroundColor = UIColor(red:04/255, green:93/255, blue:86/255, alpha:1.0)
        }else{
            AmarkAverage.text = "NA"
            AbarAverage.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0)
        }
        
        if list[4] != 0{
            OmarkAverage.text = String(round(list[4]*1000)/1000)
            ObarAverage.backgroundColor = UIColor(red:0.15, green:0.73, blue:0.22, alpha:1.0)
        }else{
            OmarkAverage.text = "NA"
            ObarAverage.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0)
        }
        
        
        KaverageWeight.text = String(list[5])
        TaverageWeight.text = String(list[6])
        CaverageWeight.text = String(list[7])
        AaverageWeight.text = String(list[8])
        OaverageWeight.text = String(list[9])
        
        UIView.animate(withDuration: 0.1, animations: {
            self.MarkBarView.layoutIfNeeded()
            self.KbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.TbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.CbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.AbarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
            self.ObarAverage.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        })
        
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
