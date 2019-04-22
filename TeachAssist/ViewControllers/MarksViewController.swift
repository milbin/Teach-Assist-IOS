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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var StackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AverageBar: UICircularProgressRing!
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
        let response = ta!.GetMarks(subjectNumber: courseNumber!)
        print(response!)
        
        if response == nil{
            return //TODO riase some error dialog
        }
        for i in 0...(response!.count - 2){
            print(i)
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
            var assignment = assignmentWithFeedbackAndTitle as! [String:[String:String?]]
            
            
            var assignmentView = AssignmentView(frame: CGRect(x: 0, y: 0, width: 350, height: 135))
            assignmentView.AssignmentTitle.text = title
            StackView.addArrangedSubview(assignmentView as UIView)
            assignmentView.TrashButton.addTarget(self, action: #selector(OnTrashButtonPress), for: .touchUpInside)
            assignmentList.append(assignmentView)
            //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OnAssignmentSelected))
            //assignmentView.addGestureRecognizer(tapGesture)
            
            StackViewHeight.constant = StackViewHeight.constant + 145
            
            
        }
        AverageBar.startProgress(to: CGFloat(Mark!), duration: 1.5)
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
        var assignmentNumber = -1
        for assignment in StackView.arrangedSubviews{
            if view == assignment{
                //response!.remove(at: assignmentNumber)
                //AverageBar.value = CGFloat(ta.CalculateAverage(response: response!))
            }
            assignmentNumber += 1
        }
        
        view?.isHidden = true
        view?.removeFromSuperview()
        StackView.layoutIfNeeded()
        StackViewHeight.constant -= 145
        
        
        
        
    }
    
    @objc func OnAssignmentSelected(gesture: UIGestureRecognizer){
        //expand view
    }
    
    
    
    
    
}
