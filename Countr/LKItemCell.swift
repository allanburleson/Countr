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
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    /**
    The action to be executed when the user taps the cell
    */
    var shortPressAction: () -> () = {}
    
    /**
    The action to be executed when the user long-presses the cell
    */
    var longPressAction: () -> () = {}
    
    /**
    The countdown item to be displayed in the cell
    */
    var countdownItem: LKCountdownItem! {
        didSet {
            self.titleLabel.text = self.countdownItem.name
            self.countdownLabel.text = self.countdownItem.remaining.asString
        }
    }
    
    /**
    Updates the label displaying the time remaining
    */
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
    
    // DO NOT MAKE THESE FUNCTIONS PRIVATE, THEY ARE CALLED BY ANOTHER CLASS VIA A SELECTOR PARAMETER
    func didLongPress() {
        //println("didLongPressOnCell")
        self.longPressAction()
    }
    
    func didTap() {
        self.shortPressAction()
    }

}
