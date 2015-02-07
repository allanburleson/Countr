//
//  LKItemCell.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import UIKit

class LKItemCell: UICollectionViewCell {


    @IBOutlet weak private var countdownLabel: UILabel!

    @IBOutlet weak private var titleLabel: UILabel!
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    var shortPressAction: () -> () = {}
    var longPressAction: () -> () = {}
    
    var countdownItem: LKCountdownItem! {
        didSet {
            self.titleLabel.text = self.countdownItem.name
            self.countdownLabel.text = self.countdownItem.remaining.asString
        }
    }
    
    func updateTimeRemainignLabel() {
        self.countdownLabel.text = self.countdownItem.remaining.asString
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.countdownLabel.textColor = UIColor.whiteColor() // These values are not set in IB, as there ia a white background
        self.titleLabel.textColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.foregroundColor()
        self.layer.borderColor = UIColor.borderColor().CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTap"))
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("didLongPress"))
        
        self.addGestureRecognizer(self.tapGestureRecognizer)
        self.addGestureRecognizer(self.longPressGestureRecognizer)
    }
    
    func didLongPress() {
        //println("didLongPressOnCell")
        self.longPressAction()
    }
    
    func didTap() {
        self.shortPressAction()
    }

}
