//
//  LKSelectDayInterfaceController.swift
//  Countr
//
//  Created by Lukas Kollmer on 3/28/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import WatchKit
import Foundation


class LKSelectDayInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var selectedNumberLabel: WKInterfaceLabel!

    @IBOutlet weak var numberSelectionSlider: WKInterfaceSlider!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func numberSelectionSliderChanged(value: Float) {
        println("numberSelectionSliderChangedToFloatValue: \(value)")
    }
}
