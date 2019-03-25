//
//  CourseView.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-03-16.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit
import UICircularProgressRing

@IBDesignable
class CourseView: UIView {

    @IBOutlet weak var PeriodNumber: UILabel!
    @IBOutlet weak var RoomNumber: UILabel!
    @IBOutlet weak var ProgressBar: UICircularProgressRing!
    @IBOutlet weak var CourseCode: UILabel!
    @IBOutlet weak var CourseName: UITextView!
    @IBOutlet weak var CodeToSafe: NSLayoutConstraint!
    @IBOutlet weak var PeriodToBar: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    
    let nibName = "CourseView"
    
    
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        //contentView!.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
        ProgressBar.font = UIFont.boldSystemFont(ofSize: 25.0)
        ProgressBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = true;
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CourseView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

}
