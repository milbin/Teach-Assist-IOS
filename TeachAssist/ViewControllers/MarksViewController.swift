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
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MARKS VIEW")
        AverageBar.font = UIFont.boldSystemFont(ofSize: 25.0)
        AverageBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(OnEditButtonPress))//add edit button as the onClick method
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        if vcTitle != nil{
            self.title = vcTitle!
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        response = ta!.GetMarks(subjectNumber: courseNumber!)
        originalResponse = response!
        
        if response == nil{
            return //TODO riase some error dialog
        }
        
        //setup refresh controller to allow main view to be refreshed
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self,
                                  action: #selector(OnRefresh),
                                  for: .valueChanged)
        scrollView.refreshControl = refreshControl
        
        for i in 0...(response!.count - 2){
            var assignmentWithFeedbackAndTitle = response![String(i)]! as! [String:Any]
            var title = (assignmentWithFeedbackAndTitle["title"]! as! String).htmlUnescape()
            var feedback = (assignmentWithFeedbackAndTitle["feedback"] as? String)
            if feedback == nil{
                feedback = ""
            }else{
                feedback = feedback!.htmlUnescape()
            }
            assignmentWithFeedbackAndTitle.removeValue(forKey: "title")
            assignmentWithFeedbackAndTitle.removeValue(forKey: "feedback")
            for category in assignmentWithFeedbackAndTitle{
                var value = (category.value as! [String:String?])
                if value["mark"]! == nil{
                    value["mark"] = "0"
                }
                assignmentWithFeedbackAndTitle[category.key] = value as! [String:String]
            }
            var assignment = assignmentWithFeedbackAndTitle as! [String:[String:String]]
            
            
            
            var assignmentView = AssignmentView(frame: CGRect(x: 0, y: 0, width: 350, height: 129))
            
            assignmentView.AssignmentTitle.text = title
            
            var markList = ["K" : 0.000000001, "T" : 0.000000001, "C" : 0.000000001, "A" : 0.000000001, "" : 0.000000001]
            var weightList = ["K" : 0.0, "T" : 0.0, "C" : 0.0, "A" : 0.0, "" : 0.0]
            var stringFractionList = ["K" : "", "T" : "", "C" : "", "A" : "", "" : ""]
            let categoryList = ["K", "T", "C", "A", ""]
            
            for category in categoryList{
                if assignment[category] != nil && assignment[category]!["mark"] != nil && assignment[category]!["mark"]! == "no mark"{
                    markList[category] = 0.0
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
                        stringFractionList[category] = assignment[category]!["outOf"]!
                    }
                    
                }else{
                    weightList[category] = 0.0
                }
            }
            if markList["K"]! == 100.0{
                assignmentView.KMark.text = "100"
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
            }else if markList["A"]! == 0.000000001{
                assignmentView.AMark.text = "NA"
                assignmentView.ABarHeight.constant = 15
                assignmentView.ABar.backgroundColor = UIColor(red:0.91, green:0.12, blue:0.39, alpha:1.0) //teachassist themed pink
            }else{
                assignmentView.AMark.text = String(markList["A"]!)
                assignmentView.ABarHeight.constant = CGFloat(markList["A"]!) * 0.55 + 15
            }
            var average = (ta?.calculateAssignmentAverage(assignment: assignment, weights: response!["categories"]! as! [String:Double]))!
            if average == "100.0"{
                average = "100"
            }
            assignmentView.AssignmentMark.text =  average + "%"
            StackViewHeight.constant = StackViewHeight.constant + 139
            print(StackViewHeight.constant)
            StackView.addArrangedSubview(assignmentView as UIView)
            assignmentView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
            assignmentList.append(assignmentView)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnAssignmentSelected))
            assignmentView.addGestureRecognizer(tapGesture)
            
            
            
            
        }
        AverageBar.startProgress(to: CGFloat(Mark!), duration: 1.5)
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
            StackView.addBackground(color: UIColor.red)
            
            for assignment in StackView.arrangedSubviews{
                assignment.invalidateIntrinsicContentSize()
                assignment.layoutMargins.top = 5
                assignment.layoutMargins.bottom = 5
            }
        }
        
        
    }
    
    @objc func OnEditButtonPress(sender: UIBarButtonItem){
        print("edit Button pressed")
        var count = 0
        
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
        
        StackViewHeight.constant -= 139
        print(StackViewHeight.constant)
        
    }
    
    
    
    @objc func OnAssignmentSelected(gesture: UIGestureRecognizer){
        let view = gesture.view!
        //StackViewHeight.constant += 100
        //view.frame.size.height = view.frame.size.height + 100
       //view.clipsToBounds = true
        
    }
    
    
    
    @objc func OnRefresh() {
        print("refreshed")
        for view in StackView.arrangedSubviews{
            view.isHidden = true
            view.removeFromSuperview()
        }
        StackViewHeight.constant = 0
        AverageBar.startProgress(to: 0.0, duration: 0)
        viewDidAppear(true)
        userIsEditing = false
        
    }
    
    
    
    
    
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
