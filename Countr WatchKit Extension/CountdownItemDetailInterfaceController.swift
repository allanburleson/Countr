//
//  CountdownItemDetailInterfaceController.swift
//  Countr
//
//  Created by Lukas Kollmer on 3/28/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import WatchKit
import Foundation


class CountdownItemDetailInterfaceController: WKInterfaceController {
    
    // Interface Outlets
    @IBOutlet weak var countdownTimer: WKInterfaceTimer!
    @IBOutlet weak var countdownTitleLabel: WKInterfaceLabel!
    
    // Instance Variables
    var countdownItem: LKCountdownItem!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("CountdownItemDetailInterfaceController: awakeWithContext: \(context)")
        
        
        // Load the passed countdownObject
        self.countdownItem = context as LKCountdownItem
        
        // Configure interface objects here.
        self.countdownTimer.setDate(self.countdownItem.date)
        self.countdownTitleLabel.setText(self.countdownItem.title)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.countdownTimer.start()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        self.countdownTimer.stop()
    }
    

}
