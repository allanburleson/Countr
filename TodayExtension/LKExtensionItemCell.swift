//
//  LKExtensionItemCell.swift
//  Countr
//
//  Created by Lukas Kollmer on 1/17/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import UIKit

class LKExtensionItemCell: UITableViewCell {
    
    @IBOutlet weak private var countdownLabel: UILabel!
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    var countdownItem: LKCountdownItem! {
        didSet {
            self.titleLabel.text = self.countdownItem.name
            self.countdownLabel.text = "__PLACEHOLDER__"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
