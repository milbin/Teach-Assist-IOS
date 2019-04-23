//
//  AssignmentView.swift
//  TeachAssist
//
//  Created by hiep tran on 2019-04-19.
//  Copyright © 2019 Ben Tran. All rights reserved.
//

import UIKit

@IBDesignable
class AssignmentView: UIView {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var AssignmentTitle: UITextView!
    @IBOutlet weak var TrashButton: UIButton!
    @IBOutlet weak var AssignmentMark: UILabel!
    
    @IBOutlet weak var KBar: UIView!
    @IBOutlet weak var KMark: UILabel!
    @IBOutlet weak var KBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var TBar: UIView!
    @IBOutlet weak var TMark: UILabel!
    @IBOutlet weak var TBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var CBar: UIView!
    @IBOutlet weak var CMark: UILabel!
    @IBOutlet weak var CBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ABar: UIView!
    @IBOutlet weak var AMark: UILabel!
    @IBOutlet weak var ABarHeight: NSLayoutConstraint!
    
    
    
    
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
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        //KBar.layer.cornerRadius = 10
        //KBar.layer.masksToBounds = true
        
        //round top 2 corners of each mark bar
        KBar.layer.cornerRadius = 5
        KBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        TBar.layer.cornerRadius = 5
        TBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        CBar.layer.cornerRadius = 5
        CBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        ABar.layer.cornerRadius = 5
        ABar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AssignmentView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    
    
    
    
}

