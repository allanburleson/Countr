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

typealias LKCountdownMode = UIDatePickerMode


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
    
    var numberOfItems: Int {
        get {
            return self.items().count
        }
    }
    
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
    
    
    func items() -> [LKCountdownItem]! {
        return self.model.items
    }
    
    func reload() {
        self.model.reloadItems()
    }
    
    func startUpdates() {
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    
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
    
    func updateCellAtItem(item: Int) {
        self.items()[item].updateTimeRemaining()
    }
    
    
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
    
    func deleteCountdownItem(item: LKCountdownItem) {
        self.model.deleteItem(item)
        
        self.didDeleteItemCompletionClosure(item: item)
        
        if self.items().isEmpty {
            //println("isEmpty")
            self.endUpdates()
        }
    }
    
    func deleteAllItems(completionHandler: () -> ()) {
        self.model.deleteAllItems(completionHandler)
        self.didDeleteAllItemsCompletionClosure()
    }
    
    
    
}

class LKCountdownItem: NSObject, Printable {
    
    let name: String!
    let date: NSDate!
    let id: String!
    let countdownMode: LKCountdownMode!
    
    let managedObject: NSManagedObject!
    
    var timeUpdatedClosure: () -> () = {}
    
    private(set) var remaining: TimeRemaining = TimeRemaining()
    
    struct TimeRemaining {
        private(set) var days: Int = 0
        private(set) var hours: Int = 0
        private(set) var minutes: Int = 0
        private(set) var seconds: Int = 0
        private(set) var asString: String = "000 : 00 : 00 : 00"
    }
    
    init(name: String, date: NSDate, mode: LKCountdownMode) {
        self.name = name
        self.date = NSCalendar.currentCalendar().dateBySettingHour(date.hour, minute: date.minute, second: 00, ofDate: date, options: nil)
        //self.date = date
        let uuid = NSUUID().UUIDString
        //println("uuid used for saving: \(uuid)")
        self.id = uuid
        self.countdownMode = mode
    }
    
    init(object: NSManagedObject) {
        self.name = object.valueForKey(coreDataNameKey) as String
        self.date = object.valueForKey(coreDataDateKey) as NSDate
        self.id = object.valueForKey(coreDataIdKey) as String
        //println("countdownmode: \(object.valueForKey(coreDataKindKey) as String)")
        self.countdownMode = LKCountdownMode(string: object.valueForKey(coreDataKindKey) as String)
        self.managedObject = object
    }
    
    init(cloudRecord: CKRecord) {
        //println("input cloudRecord: \(cloudRecord)")
        
        self.name = cloudRecord.valueForKey(countdownItemRecordNameKey) as String
        self.date = cloudRecord.valueForKey(countdownItemRecordDateKey) as NSDate
        self.id = cloudRecord.valueForKey(countdownItemRecordIdKey) as String
    }
    
    
    func updateTimeRemaining() {
        
        //println("updateTimeRemaining")
        
        let calendar = NSCalendar.currentCalendar()
        
        let unitFlags = NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: NSDate(), toDate: self.date, options: nil)
        
        self.remaining.days = components.day
        self.remaining.hours = components.hour
        self.remaining.minutes = components.minute
        self.remaining.seconds = components.second
        self.remaining.asString = "\(self.remaining.days) : \(self.remaining.hours) : \(self.remaining.minutes) : \(self.remaining.seconds)"
        
    }
    
    
    override var description: String {
        get {
            //return "LKCountdownItem: Name: \(self.name), Reference date: \(self.date))"
            return "LKCountdownItem: Name: \(self.name), Reference date: \(self.date), uuid: \(self.id), countdownMode: \(self.countdownMode.toString())"
        }
    }
    
    // TODO: calculate the current time for updating at the same time for all items. A way to achive this would be to add a manager property to all items and then add a time property to the manager, the time propetzy of teh manager would be updated at teh beginning of each update cycle (in the maneger class)
}

extension LKCountdownItem {
    func isEqualToCountdownItem(item: LKCountdownItem) -> Bool {
        return self.id == item.id
    }
}

extension LKCountdownMode {
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