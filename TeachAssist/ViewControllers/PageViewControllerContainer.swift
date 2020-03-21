//
//  PageViewControllerContainer.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-03-21.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import Foundation
import UIKit
class PageViewControllerContainer: UIViewController{
    var Mark:Double? = nil
    var courseNumber:Int? = nil
    var ta:TA? = nil
    var vcTitle:String? = nil
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = storyboard!.instantiateViewController(withIdentifier: "CourseInfoPageViewController") as! CourseInfoPageViewController
        vc.Mark = Mark
        vc.courseNumber = courseNumber
        vc.ta = ta
        vc.vcTitle = vcTitle
        addChild(vc)
        //vc.view.frame = ...  // or, better, turn off `translatesAutoresizingMaskIntoConstraints` and then define constraints for this subview
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
}
