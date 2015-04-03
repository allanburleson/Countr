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
    var didDeleteItemCompletionClosure: (item: LKCountdownItem) -> ()
    var didDeleteAllItemsCompletionClosure: () -> ()
    
    /**
    The number of countdown items
    
    :returns: The number of items as an Int object
    */
    var numberOfItems: Int {
        get {
            return self.items().count
        }
    }
    
    /**
    Indicates if the user currently can add new countdown items
    
    :returns: A bool indicating if the user can add new countdwown items
    
    
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
        self.didAddNewItemCompletionClosure = {(item: LKCountdownItem) in}
        self.didDeleteItemCompletionClosure = {(item: LKCountdownItem) in}
        self.didDeleteAllItemsCompletionClosure = {}
        super.init()
    }
    
    /**
    All countdown items
    
    :returns: An Array of LKCountdownItem objects

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
    
    :param: itemID The UUID of the item you want to recive (As String)
    :returns: The countdownItem with the provided id
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
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    /**
    Stop updating the timeRemaining property of all countdown items in self.items
    */
    func endUpdates() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }
    
    
    func update() {
        
        for item in self.items() {
            
            item.updateTimeRemaining()
            
        }
        
        self.updateCompletionClosure()

    }
    
    /**
    Update the remaining time property of the countown item at a certain indexPath
    
    :param: item The item var of the items indexPath
    */
    func updateCellAtItem(item: Int) {
        self.items()[item].updateTimeRemaining()
    }
    
    /**
    Save a new countdown item
    
    :param: item The item to be saved
    :param: countdownMode The Mode of the item (either Date or DateAndTime)
    :param: completionHandler A closure which is executed when the item was sucessfully saved
    */
    func saveNewCountdownItem(item: LKCountdownItem, countdownMode: LKCountdownMode, completionHandler: () -> Void) {
        var adaptedItem: LKCountdownItem!
        
        /*
        switch countdownMode {
        case .Date:
            let date: NSDate = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: item.date, options: nil)!
            adaptedItem = LKCountdownItem(name: item.name, date: date)
            break
        case .DateAndTime:
            let date: NSDate = NSCalendar.currentCalendar().dateBySettingHour(item.date.hour, minute: item.date.minute, second: 0, ofDate: item.date, options: nil)!
            adaptedItem = LKCountdownItem(name: item.name, date: date)
            break
        default:
            break
        }
*/
        
        //self.model.saveNewItem(adaptedItem)
        self.model.saveNewItem(item)
        //println("did succed saving the item")
        completionHandler()
        self.didAddNewItemCompletionClosure(item: item)

    }
    /**
    Delete a countdown item
    
    :param: item The item to be deleted
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
    
    :param: completionHandler A closure which is executed when all items were sucessfully deleted
    */
    func deleteAllItems(completionHandler: () -> ()) {
        self.model.deleteAllItems(completionHandler)
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
class LKCountdownItem: NSObject, Printable {
    
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
    
    
    /**
    Create a new Countdown Item manually
    
    :param: name The title of the item
    :param: date The date to which the item counts
    :param: mode The countdown mode (either Date or DateAndTime)
    :param: id default the UUID of th eitem. Can be omitted when creating new countdown items. Only used in today extension
    */
    init(title: String, date: NSDate, mode: LKCountdownMode, id: NSUUID = NSUUID()) {
        self.title = title
        self.date = NSCalendar.currentCalendar().dateBySettingHour(date.hour, minute: date.minute, second: 00, ofDate: date, options: nil)
        //self.date = date
        //println("uuid used for saving: \(uuid)")
        self.id = id.UUIDString
        self.countdownMode = mode
    }
    
    /**
    Create a new countdown item from an NSManagedObject
    
    :param: object The NSManagedObject to use when the item is created
    */
    init(object: NSManagedObject) {
        self.title = object.valueForKey(coreDataTitleKey) as String
        self.date = object.valueForKey(coreDataDateKey) as NSDate
        self.id = object.valueForKey(coreDataIdKey) as String
        //println("countdownmode: \(object.valueForKey(coreDataKindKey) as String)")
        self.countdownMode = LKCountdownMode(string: object.valueForKey(coreDataKindKey) as String)
        self.managedObject = object
    }
    
    /**
    Create a new countdown item from an CKRecord
    
    :param: cloudRecord The CKReckord to use when the item is created
    */
    init(cloudRecord: CKRecord) {
        //println("input cloudRecord: \(cloudRecord)")
        
        self.title = cloudRecord.valueForKey(countdownItemRecordNameKey) as String
        self.date = cloudRecord.valueForKey(countdownItemRecordDateKey) as NSDate
        self.id = cloudRecord.valueForKey(countdownItemRecordIdKey) as String
    }
    
    /**
    Update the remaining property
    */
    func updateTimeRemaining() {
        
        //println("updateTimeRemaining")
        
        let calendar = NSCalendar.currentCalendar()
        
        let unitFlags = NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: NSDate(), toDate: self.date, options: nil)
        
        self.remaining.days = components.day
        self.remaining.hours = components.hour
        self.remaining.minutes = components.minute
        self.remaining.seconds = components.second
        self.remaining.asString = "\(self.remaining.days.positive) : \(self.remaining.hours.positive) : \(self.remaining.minutes.positive) : \(self.remaining.seconds.positive)"
        
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
    Delete all countdown items
    
    :param: item The countdown item to compare the current item with
    */
    func isEqualToCountdownItem(item: LKCountdownItem) -> Bool {
        return self.id == item.id
    }
}

extension LKCountdownMode {
    
    /**
    Init a new LKCountdownMode object from a string
    
    :param: string The String to be used for creating the LKCountdownMode object
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
    
    :returns: A string object describing the Countdown mode
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
}

extension NSDate {
    var hour: Int {
        get {
            return self.dateComponents.hour
        }
    }

    var minute: Int {
        get {
            return self.dateComponents.minute
        }
    }

    var second: Int {
        get {
            return self.dateComponents.second
        }
    }


    private var dateComponents: NSDateComponents {
        get {
            let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            let calendarUnits: NSCalendarUnit = (.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit)


            let dateComponents = calendar?.components( calendarUnits, fromDate: self)

            return dateComponents!
        }
    }


}