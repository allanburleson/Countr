//
//  GlanceController.swift
//  Countr WatchKit Extension
//
//  Created by Lukas Kollmer on 3/28/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    
    //
    // UI
    //
    
    // Item 0
    @IBOutlet weak var item0TitleLabel: WKInterfaceLabel!
    @IBOutlet weak var item0Timer: WKInterfaceTimer!
    
    // Item 1
    @IBOutlet weak var item1TitleLabel: WKInterfaceLabel!
    @IBOutlet weak var item1Timer: WKInterfaceTimer!
    
    
    //
    // Instance Variables
    //
    
    let extensionDataManager = LKSharedExtensionDataManager()
    var countdownItems: [LKCountdownItem] = []
    

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        self.countdownItems = self.extensionDataManager.loadCountdownItemsForExtensionWithType(.WatchGlance)
        println("self.countdownItems: \(self.countdownItems)")
        
        self.item0TitleLabel.setHidden(true)
        self.item0Timer.setHidden(true)
        
        self.item1TitleLabel.setHidden(true)
        self.item1Timer.setHidden(true)
        
        switch self.countdownItems.count {
        case 0:
            println("case 0:")
            
            self.item0TitleLabel.setText("No items added yet. Youn can add items in the Countr iOS app.")
            
        case 1:
            println("case 1:")
            self.item0TitleLabel.setText(self.countdownItems[0].title)
            self.item0Timer.setDate(self.countdownItems[0].date)
            self.item0Timer.start()
            
            self.item0TitleLabel.setHidden(false)
            self.item0Timer.setHidden(false)
            
        case 2:
            println("case 2:")
            self.item0TitleLabel.setText(self.countdownItems[0].title)
            self.item0Timer.setDate(self.countdownItems[0].date)
            self.item0Timer.start()
            
            self.item1TitleLabel.setText(self.countdownItems[1].title)
            self.item1Timer.setDate(self.countdownItems[1].date)
            self.item1Timer.start()
            
            self.item0TitleLabel.setHidden(false)
            self.item0Timer.setHidden(false)
            
            self.item1TitleLabel.setHidden(false)
            self.item1Timer.setHidden(false)

        default:
            println("default:")
            break
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
