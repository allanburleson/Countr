//
// Created by Lukas Kollmer on 3/15/15.
// Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

/**
A subclass of UIAlertController that uses Avenir as font
*/
class LKAlertController: UIAlertController {


    /**
    Create a new instance if LKAlertController
    
    - parameter title: The string used as title for the action sheet
    
    - parameter message: The string used as message in the action sheet
    
    - returns: An instance of LKAlertController which is configured to use the title and message as input that were given via the parameters
    */
    class func actionSheetWithTitle(title: String, message: String) -> LKAlertController {
        let alertController = LKAlertController(title: title, message: message, preferredStyle: .ActionSheet)

        let attributedTitle: NSAttributedString = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 14)!, NSForegroundColorAttributeName: UIColor.grayColor()])
        let attributedMessage: NSAttributedString = NSAttributedString(string: message, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 14)!, NSForegroundColorAttributeName: UIColor.grayColor()])

        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")

        return alertController
    }
    
    class func alertViewWithTitle(title: String, message: String) -> LKAlertController {
        let alertController = LKAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let attributedTitle: NSAttributedString = NSAttributedString(string: "\(title)\n", attributes: [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size: 17)!, NSForegroundColorAttributeName: UIColor.blackColor()])
        let attributedMessage: NSAttributedString = NSAttributedString(string: message, attributes: [NSFontAttributeName: UIFont(name: "Avenir-Roman", size: 15)!, NSForegroundColorAttributeName: UIColor.blackColor()])
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        return alertController
    }

}
