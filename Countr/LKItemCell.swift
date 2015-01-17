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
    
    private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
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
        self.backgroundColor = UIColor.orangeColor()
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("didLongPress"))
        
        self.addGestureRecognizer(self.longPressGestureRecognizer)
    }
    
    func didLongPress() {
        println("didLongPressOnCell")
        self.longPressAction()
    }

}
