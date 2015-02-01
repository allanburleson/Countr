//
//  LKPurchasePremiumCell.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/31/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import UIKit

class LKPurchasePremiumCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    var shortPressAction: () -> () = {}
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let white = UIColor.whiteColor()
        self.titleLabel.textColor = white
        self.descriptionLabel.textColor = white
        self.backgroundColor = UIColor(rgba: "#252525")
        self.layer.borderColor = UIColor(rgba: "#292929").CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        self.titleLabel.font = UIFont(name: "Avenir-Book", size: 17)
        self.descriptionLabel.font = UIFont(name: "Avenir-Book", size: 13)
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTap"))
        
        self.addGestureRecognizer(self.tapGestureRecognizer)

    }
    
    
    func didTap() {
        self.shortPressAction()
    }

}
