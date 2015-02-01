//
//  LKRoundBorderedButton.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/31/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

// TODO: add a bool allowing to disable interaction (eg: loading the price from the itunes store: the button is not grayed out but has no (user) interaction enabled
@IBDesignable
class LKRoundBorderedButton: UIButton {
    
    @IBInspectable var plusIconVisible: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var enabled: Bool {
        didSet {
            super.enabled = self.enabled
            self.refreshBorderColor()
        }
    }
    
    @IBInspectable override var tintColor: UIColor? {
        didSet {
            super.tintColor = self.tintColor
            self.setTitleColor(self.tintColor, forState: .Normal)
            self.setTitleColor(self.tintColor, forState: .Disabled)
            self.refreshBorderColor()
        }
    }
    
    override var highlighted: Bool {
        didSet {
            println("highlighted: \(highlighted)")
            super.highlighted = self.highlighted
            
            UIView.animateWithDuration(0.25, animations: {
                self.layer.backgroundColor = self.highlighted ? self.tintColor?.CGColor : UIColor.clearColor().CGColor
            })
            
            self.setNeedsDisplay()
            
        }
    }
    
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    
    func commonInit() {
        self.tintColor = super.tintColor
        self.setTitleColor(self.tintColor, forState: .Normal)
        self.setTitleColor(UIColor(rgba: "#232323"), forState: .Highlighted)
        self.setTitleColor(self.tintColor, forState: .Disabled)
        
        self.titleLabel?.font = UIFont.boldSystemFontOfSize(10)
        
        self.layer.cornerRadius = 3.5
        self.layer.borderWidth = 1
        
        self.refreshBorderColor()
        
    }
    
    
    func refreshBorderColor() {
        self.layer.borderColor = self.enabled ? self.tintColor?.CGColor : UIColor.grayColor().CGColor
    }
    
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let org = super.sizeThatFits(self.bounds.size)
        
        return CGSizeMake(org.width + 20, org.height - 2);

    }
    
    override func drawRect(rect: CGRect) {
        
        let contextRef: CGContextRef = UIGraphicsGetCurrentContext()
        
        if self.plusIconVisible {
            var color: UIColor
            
            if self.highlighted {
                color = UIColor.whiteColor()
            } else if !self.enabled {
                color = UIColor.grayColor()
            } else {
                color = self.tintColor!
            }
            
            CGContextSetFillColorWithColor(contextRef, color.CGColor)
            
            let verticalBar = CGRectMake(5, 3, 1, 5)
            CGContextFillRect(contextRef, verticalBar)
            
            let horizontalBar = CGRectMake(3, 5, 5, 1)
            CGContextFillRect(contextRef, horizontalBar)
        }
        
    }
    
}