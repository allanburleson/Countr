//
//  InterfaceController.swift
//  Countr WatchKit Extension
//
//  Created by Lukas Kollmer on 3/28/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import WatchKit
import Foundation

/**
The WatchKit InterfaceController which controls the main table of the watch app
*/
class LKMainTableInterfaceController: WKInterfaceController {
    
    // Interface outlets
    @IBOutlet weak var countdownItemsTable: WKInterfaceTable!
    
    // Instance variables
    let extensionDataManager = LKSharedExtensionDataManager()
    var countdownItems: [LKCountdownItem] = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        println("awakeWithContext: \(context)")
        
        // Configure interface objects here.
        self.setTitle("Countr")
        countdownItems = extensionDataManager.loadCountdownItemsForExtensionWithType(.WatchApp)
        
        self.countdownItemsTable.setNumberOfRows(countdownItems.count, withRowType: "LKCountdownItemRowController")
        
        let rowCount = self.countdownItemsTable.numberOfRows
        
        // Iterate over the rows and set the label for each one.
        for (var index = 0; index < rowCount; index++) {
            // Get the to-do item data.
            let countdownItem = self.countdownItems[index]
            
            // Assign the text to the row's label.
            let rowController: LKCountdownItemRowController = self.countdownItemsTable.rowControllerAtIndex(index) as LKCountdownItemRowController
            rowController.item = countdownItem
        }
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        // Start all timers when the view appears
        let rowCount = self.countdownItemsTable.numberOfRows
        
        // Iterate over the rows and set the label for each one.
        for (var index = 0; index < rowCount; index++) {
            let rowController: LKCountdownItemRowController = self.countdownItemsTable.rowControllerAtIndex(index) as LKCountdownItemRowController
            rowController.countdownTimer.start()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        
        // Stop all timers when the view disappears
        let rowCount = self.countdownItemsTable.numberOfRows
        
        // Iterate over the rows and set the label for each one.
        for (var index = 0; index < rowCount; index++) {
            let rowController: LKCountdownItemRowController = self.countdownItemsTable.rowControllerAtIndex(index) as LKCountdownItemRowController
            rowController.countdownTimer.stop()
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        println("tableDidSelectRowAtIndex: \(rowIndex)")
        
        self.pushControllerWithName("CountdownItemDetailInterfaceController", context: self.countdownItems[rowIndex])
    }

}


class LKCountdownItemRowController: NSObject {
    
    var item: LKCountdownItem! {
        didSet {
            self.titleLabel.setText(self.item.name)
            self.countdownTimer.setDate(self.item.date)
            self.countdownTimer.start()
        }
    }
    
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var countdownTimer: WKInterfaceTimer!
}