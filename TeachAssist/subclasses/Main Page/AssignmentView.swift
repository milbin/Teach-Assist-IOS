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
    
    
    @IBOutlet weak var ABar: UIView!
    @IBOutlet weak var AMark: UILabel!
    
    @IBOutlet weak var CBar: UIView!
    @IBOutlet weak var CMark: UILabel!
    
    @IBOutlet weak var TBar: UIView!
    @IBOutlet weak var TMark: UILabel!
    
    @IBOutlet weak var KBar: UIView!
    @IBOutlet weak var KMark: UILabel!
    
    
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
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AssignmentView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    
    
    
    
}

