//
//  LKCountdown.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

public let didDeleteAllItemsKey = "didDeleteAllItems"
public let didDeleteAnItemKey = "didDeleteAnItem"

/**
The modes a countdown can have

Possible modes are:

-  Date
-  DateAndTime

*/
typealias LKCountdownMode = UIDatePickerMode

/**
The Main class for managing the countdown Items
*/
class LKCountdownManager: NSObject {

    class var sharedInstance : LKCountdownManager {
        struct Static {
            static let instance : LKCountdownManager = LKCountdownManager()
        }
        return Static.instance
    }

    private let model = LKModel.sharedInstance



    private var updateTimer: NSTimer?


    var updateCompletionClosure: () -> ()
    //var didAddNewItemConpletionClosure: () -> () = {}
    var didAddNewItemCompletionClosure: (item: LKCountdownItem) -> ()
    var didEditItemConpletionClosure: (item: LKCountdownItem) -> ()
    var didDeleteItemCompletionClosure: (item: LKCountdownItem) -> ()
    var didDeleteAllItemsCompletionClosure: () -> ()

    /**
    The number of countdown items

    - returns: The number of items as an Int object
    */
    var numberOfItems: Int {
        get {
            return self.items().count
        }
    }

    /**
    Indicates if the user currently can add new countdown items

    - returns: A bool indicating if the user can add new countdwown items


    */
    var canAddCountdowns: Bool {
        get {
            //println("self.items.count = \(self.numberOfItems)")
            if LKPurchaseManager.didPurchase {
                //println("did purchase, will return true")
               return true
            } else {
                let usesAllAvailableSpots: Bool = self.numberOfItems >= 2
                //println("usesAllAvailableSpots: \(usesAllAvailableSpots)")
                return !usesAllAvailableSpots
            }
        }
    }

    override init() {
        self.updateCompletionClosure = {}
        self.didAddNewItemCompletionClosure     = {(item: LKCountdownItem) in}
        self.didEditItemConpletionClosure       = {(item: LKCountdownItem) in}
        self.didDeleteItemCompletionClosure     = {(item: LKCountdownItem) in}
        self.didDeleteAllItemsCompletionClosure = {}

        super.init()
    }

    /**
    All countdown items

    - returns: An Array of LKCountdownItem objects

    */
    func items() -> [LKCountdownItem]! {
        return self.model.items
    }

    /**
    All Countdown items where the data equals todays date
    */
    func itemsDueToday() -> [LKCountdownItem] {
        let allItems = self.model.items
        var _todayItems: [LKCountdownItem] = []

        for item in allItems {
            if item.date.isToday {
                _todayItems.append(item)
            }
        }

        return _todayItems
    }

    /**
    Get the countdown item with the provided id

    - parameter itemID: The UUID of the item you want to recive (As String)
    - returns: The countdownItem with the provided id
    */
    func itemWithID(itemID: String) -> LKCountdownItem? {
        for item in self.items() {
            if item.id == itemID {
                return item
            }
        }

        return nil
    }

    /**
    Reload the countdown items from the CoreData model
    */
    func reload() {
        self.model.reloadItems()
    }

    /**
    Start updating the timeRemaining property of all countdown items in self.items
    */
    func startUpdates() {
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }

    /**
    Stop updating the timeRemaining property of all countdown items in self.items
    */
    func endUpdates() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }


    /**
    Update all countdown items. This updates the timeRemaining properties
    */
    func update() {

        for item in self.items() {

            item.updateTimeRemaining()

        }

        self.updateCompletionClosure()

    }

    /**
    Update the remaining time property of the countown item at a certain indexPath

    - parameter item: The item var of the items indexPath
    */
    func updateCellAtItem(item: Int) {
        self.items()[item].updateTimeRemaining()
    }

    /**
    Save a new countdown item

    - parameter item: The item to be saved
    - parameter countdownMode: The Mode of the item (either Date or DateAndTime)
    - parameter completionHandler: A closure which is executed when the item was sucessfully saved
    */
    func saveNewCountdownItem(item: LKCountdownItem, completionHandler: (() -> Void)?) {


        self.model.saveNewItem(item)
        completionHandler?()
        self.didAddNewItemCompletionClosure(item: item)

    }


    /**
    Update an countdownItem in the data stack

    - parameter oldItem: The countdownItem you wish to update
    - parameter newItem: The updated countdownItem
    */
    func updateCountdownItem(oldItem: LKCountdownItem, withCountdownItem newItem: LKCountdownItem) {
        self.model.updateItem(oldItem, withItem: newItem) {
            self.didEditItemConpletionClosure(item: newItem)
        }
    }

    /**
    Delete a countdown item

    - parameter item: The item to be deleted
    */
    func deleteCountdownItem(item: LKCountdownItem) {
        self.model.deleteItem(item)

        self.didDeleteItemCompletionClosure(item: item)

        if self.items().isEmpty {
            //println("isEmpty")
            self.endUpdates()
        }
    }
    /**
    Delete all countdown items

    - parameter completionHandler: A closure which is executed when all items were sucessfully deleted
    */
    func deleteAllItems(completionHandler: (success: Bool) -> ()) {
        self.model.deleteAllItems(completionHandler: completionHandler)
        self.didDeleteAllItemsCompletionClosure()
    }

    /**
    Save the countdown items to the Today Extension
    */
    func saveDataForExtension() {
        self.model.saveDataForExtension()
    }


}

/**
A struct representing the time remaining to a certain date

Available properties are (all readonly):

- days: (Int)
- hours: (Int)
- minutes: (Int)
- seconds: (Int)
*/
public struct TimeRemaining {
    /**
    The number of days left to a certain date
    */
    private(set) var days: Int = 0
    /**
    The number of hours left to a certain date
    */
    private(set) var hours: Int = 0
    /**
    The number of minutes left to a certain date
    */
    private(set) var minutes: Int = 0
    /**
    The number of seconds left to a certain date
    */
    private(set) var seconds: Int = 0
    /**
    The time Remaining to a certain date, as a string

    Example: "150 : 21 : 27 : 45" (days : hrs : mins : secs)
    */
    private(set) var asString: String = ""
}

/**
A countdown item
*/
class LKCountdownItem: NSObject {

    let title: String!
    let date: NSDate!
    let id: String!
    let countdownMode: LKCountdownMode!

    /**
    The managedObject of which the countdownItem was created
    */
    let managedObject: NSManagedObject!

    /**
    A Closure which is executed every time the remaining time of the countdown item was updated
    */
    var timeUpdatedClosure: () -> () = {}

    /**
    The time remaining to the reference date
    */
    private(set) var remaining: TimeRemaining = TimeRemaining()


    /*
    Returns a description that can be used for sharing
    Example: "Only 30 days 3 hours 7 minutes left to WWDC '15"

    // TODO: Localize this!
    */
    var shareDescription: String {
        var shareString = ""
        let onlyString   = NSLocalizedString("me.kollmer.countr.shareItemShareSheet.only", comment: "")
        let sinceString  = NSLocalizedString("me.kollmer.countr.shareItemShareSheet.since", comment: "")
        let leftToString = NSLocalizedString("me.kollmer.countr.shareItemShareSheet.leftTo", comment: "")

        if !self.date.isPast {
            shareString += "\(onlyString) "
        }
        if self.remaining.days != 0 {
            shareString += "\(self.remaining.days.positive)d " // Add days
        }
        shareString += "\(self.remaining.hours.positive)h \(self.remaining.minutes.positive)m " // add hours + minutes

        if self.date.isPast {
            shareString += "\(sinceString) "
        } else {
            shareString += "\(leftToString) "
        }

        shareString += "\(self.title)"

        return shareString
    }


    /**
    Create a new Countdown Item manually

    - parameter name: The title of the item
    - parameter date: The date to which the item counts
    - parameter mode: The countdown mode (either Date or DateAndTime)
    - parameter id: default the UUID of th eitem. Can be omitted when creating new countdown items. Only used in today extension
    */
    init(title: String, date: NSDate, mode: LKCountdownMode, id: NSUUID = NSUUID()) {
        self.title = title
        self.date = NSCalendar.currentCalendar().dateBySettingHour(date.hour, minute: date.minute, second: 00, ofDate: date, options: []) as NSDate!
        //self.date = date
        //println("uuid used for saving: \(uuid)")
        self.id = id.UUIDString
        self.countdownMode = mode
        self.managedObject = nil
    }

    /**
    Create a new countdown item from an NSManagedObject

    - parameter object: The NSManagedObject to use when the item is created
    */
    init(object: NSManagedObject) {
        self.title = object.valueForKey(coreDataTitleKey) as! String
        self.date = object.valueForKey(coreDataDateKey) as! NSDate
        self.id = object.valueForKey(coreDataIdKey) as! String
        //println("countdownmode: \(object.valueForKey(coreDataKindKey) as String)")
        self.countdownMode = LKCountdownMode(string: object.valueForKey(coreDataKindKey) as! String)
        self.managedObject = object
    }

    /**
    Update the remaining property
    */
    func updateTimeRemaining() {

        //println("updateTimeRemaining")

        let calendar = NSCalendar.currentCalendar()

        let unitFlags: NSCalendarUnit = [NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: NSDate(), toDate: self.date, options: [])


        self.remaining.days = components.day
        self.remaining.hours = components.hour
        self.remaining.minutes = components.minute
        self.remaining.seconds = components.second


        // Add leading integer digits for the display string

        let formattedDays = self.remaining.days.positive.toStringWithNumberOfLeadingDigits(3)!
        let formattedHours = self.remaining.hours.positive.toStringWithNumberOfLeadingDigits(2)!
        let formattedMinutes = self.remaining.minutes.positive.toStringWithNumberOfLeadingDigits(2)!
        let formattedSeconds = self.remaining.seconds.positive.toStringWithNumberOfLeadingDigits(2)!
        self.remaining.asString = "\(formattedDays)d : \(formattedHours) : \(formattedMinutes) : \(formattedSeconds)"

    }


    override var description: String {
        get {
            //return "LKCountdownItem: Name: \(self.name), Reference date: \(self.date))"
            return "LKCountdownItem: Name: \(self.title), Reference date: \(self.date), uuid: \(self.id), countdownMode: \(self.countdownMode.toString())"
        }
    }

    // TODO: calculate the current time for updating at the same time for all items. A way to achive this would be to add a manager property to all items and then add a time property to the manager, the time propetzy of teh manager would be updated at teh beginning of each update cycle (in the maneger class)
}

extension LKCountdownItem {

    /**
    Compare two countdown items

    - parameter item: The countdown item to compare the current item with
    */
    func isEqualToCountdownItem(item: LKCountdownItem) -> Bool {
        return self.id == item.id
    }
}

extension LKCountdownMode {

    /**
    Init a new LKCountdownMode object from a string

    - parameter string: The String to be used for creating the LKCountdownMode object
    */
    init(string: String) {
        if string == coreDataKindDateKey {
            self = .Date
            return
        }

        if string == coreDataKindDateAndTimeKey {
            self = .DateAndTime
            return
        }

        self = .Date
    }

    /**
    Get a string representation of the countdown mode

    - returns: A string object describing the Countdown mode
    */
    func toString() -> String {
        switch self {
        case .Date:
            return coreDataKindDateKey
        case .DateAndTime:
            return coreDataKindDateAndTimeKey
        default:
            return coreDataKindUnknownKey
        }
    }

    func description() -> String {
        return self.toString()
    }
}
