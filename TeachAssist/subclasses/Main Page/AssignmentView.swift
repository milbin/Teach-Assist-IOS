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
    @IBOutlet weak var KBarWidth: NSLayoutConstraint!
    @IBOutlet weak var KBarBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var KMark: UILabel!
    @IBOutlet weak var KBarHeight: NSLayoutConstraint!
    @IBOutlet weak var KWeight: UILabel!
    @IBOutlet weak var KFraction: UILabel!

    
    @IBOutlet weak var TBar: UIView!
    @IBOutlet weak var TBarWidth: NSLayoutConstraint!
    @IBOutlet weak var TBarBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var TMark: UILabel!
    @IBOutlet weak var TBarHeight: NSLayoutConstraint!
    @IBOutlet weak var TWeight: UILabel!
    @IBOutlet weak var TFraction: UILabel!
    
    @IBOutlet weak var CBar: UIView!
    @IBOutlet weak var CBarWidth: NSLayoutConstraint!
    @IBOutlet weak var CBarBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var CMark: UILabel!
    @IBOutlet weak var CBarHeight: NSLayoutConstraint!
    @IBOutlet weak var CWeight: UILabel!
    @IBOutlet weak var CFraction: UILabel!
    
    @IBOutlet weak var ABar: UIView!
    @IBOutlet weak var ABarWidth: NSLayoutConstraint!
    @IBOutlet weak var ABarBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var AMark: UILabel!
    @IBOutlet weak var ABarHeight: NSLayoutConstraint!
    @IBOutlet weak var AWeight: UILabel!
    @IBOutlet weak var AFraction: UILabel!
    
    @IBOutlet weak var OBar: UIView!
    @IBOutlet weak var OBarWidth: NSLayoutConstraint!
    @IBOutlet weak var OBarBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var OBarHeight: NSLayoutConstraint!
    @IBOutlet weak var OMark: UILabel!
    @IBOutlet weak var OWeight: UILabel!
    @IBOutlet weak var OFraction: UILabel!
    
    @IBOutlet weak var feedback: UITextView!
    @IBOutlet weak var centerAverageConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint!
    var height = 129
    
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
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
        //self.translatesAutoresizingMaskIntoConstraints = true
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
        contentView.layer.cornerRadius = 15
        
        //KBar.layer.cornerRadius = 10
        //KBar.layer.masksToBounds = true
        
        
            
        KBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        TBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        CBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        ABar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
        OBar.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 5)
    
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AssignmentView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 355, height: height)
    }
    
    
    func toggleState(newHeight:Int) -> Bool{
        if height == 129{
            height += newHeight
            UIView.animate(withDuration: 0.1, animations: {
                self.invalidateIntrinsicContentSize()
                self.contentView.heightAnchor.constraint(equalToConstant: CGFloat(self.height))
                self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.contentView.frame.minY, width: self.contentView.frame.width, height: CGFloat(self.height))
                
            })
            return true
        }else{
            height = 129
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView.heightAnchor.constraint(equalToConstant: CGFloat(self.height))
                self.contentView.frame = CGRect(x: self.contentView.frame.minX, y: self.contentView.frame.minY, width: self.contentView.frame.width, height: CGFloat(self.height))
                
            })
            self.invalidateIntrinsicContentSize()
            return false
        }
    }
    
    
    
    
    
    
    
    
}

