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
    
    /**
    The WKInterfaceTable used for displaying the countdowns
    */
    @IBOutlet weak var countdownItemsTable: WKInterfaceTable!
    
    /**
    The label hidden behind the countdownItemsTable for displaying a message to the user
    */
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    
    // Instance variables
    let extensionDataManager = LKSharedExtensionDataManager()
    var countdownItems: [LKCountdownItem] = []
    
    /**
    A value determining wheter the UI should display buttons for adding new items
    */
    var shouldDisplayAddItemButton: Bool {
        return false
    }

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.messageLabel.setHidden(true)
        println("awakeWithContext: \(context)")
        
        //self.addMenuItemWithItemIcon(.Add, title: "Add", action: "addNewItem")
        // Configure interface objects here.
        self.setTitle("Countr")
        countdownItems = extensionDataManager.loadCountdownItemsForExtensionWithType(.WatchApp)
        println("items loeded from extension manager: \(countdownItems)")
        
        if !countdownItems.isEmpty {
            var rowTypes: [String] = [] // Add row:  = ["LKAddItemRowController"]
            for item in self.countdownItems {
                rowTypes.append("LKCountdownItemRowController")
            }
            self.countdownItemsTable.setRowTypes(rowTypes)
            
            let rowCount = self.countdownItemsTable.numberOfRows
            
            // Iterate over the rows and set the label for each one.
            for (var index = 0; index < rowCount; index++) {
                
                let rowController: LKCountdownItemRowController = self.countdownItemsTable.rowControllerAtIndex(index) as LKCountdownItemRowController
                rowController.item = self.countdownItems[index]
            }

        } else {
            // The countdownItems array is empty
            self.countdownItemsTable.setHidden(true)
            self.messageLabel.setText(NSLocalizedString("me.kollmer.countr.watch.emptyTableMessage", comment: "")) //TODO: Localize this
            self.messageLabel.setHidden(false)
        }
        
    }
    func addNewItem() {
        println("add new item function called")
        WKInterfaceController.openParentApplication([wk_action_key : wk_action_addNewItem_key], reply: nil)
        //self.pushControllerWithName("LKAddItemInterfaceController", context: nil)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
        // Start all timers when the view appears
        let rowCount = self.countdownItemsTable.numberOfRows
        
        // Iterate over the rows and start all timers.
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
        
        // Iterate over the rows and stop all timers.
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

class LKAddItemRowController: NSObject {
    @IBOutlet weak var imageView: WKInterfaceImage!
}