//
// Created by Lukas Kollmer on 3/15/15.
// Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit


class LKAlertController: UIAlertController {


    class func actionSheetWithTitle(title: String, message: String) -> LKAlertController {
        let alertController = LKAlertController(title: title, message: message, preferredStyle: .ActionSheet)

        let attributedTitle: NSAttributedString = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 14)!, NSForegroundColorAttributeName: UIColor.grayColor()])
        let attributedMessage: NSAttributedString = NSAttributedString(string: message, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 14)!, NSForegroundColorAttributeName: UIColor.grayColor()])

        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")

        return alertController
    }

}
