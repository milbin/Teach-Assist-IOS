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
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var NATextView: UITextView!
    @IBOutlet weak var TrashButton: UIButton!
    
    @IBOutlet weak var ProgressBarWidth: NSLayoutConstraint!
    @IBOutlet weak var ProgressBarHeight: NSLayoutConstraint!
    
    
    
        
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
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor(red:39/255, green:39/255, blue: 47/255, alpha:1).cgColor
        contentView.layer.cornerRadius = 15
        ProgressBar.font =  UIFont(name: "Gilroy-Bold", size: 20)!
        ProgressBar.fontColor = UIColor.white
        ProgressBar.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint:true, decimalPlaces:1)
                    
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CourseView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }

}
