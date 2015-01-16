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


class LKCountdownManager: NSObject {
    
    class var sharedInstance : LKCountdownManager {
        struct Static {
            static let instance : LKCountdownManager = LKCountdownManager()
        }
        return Static.instance
    }
    
    private let model = LKModel.sharedInstance
    
    
    
    private var updateTimer: NSTimer?
    
    
    var updateCompletionClosure: () -> () = {}
    var didAddNewItemConpletionClosure: () -> () = {}
    
    var numberOfItems: Int {
        get {
            return self.items().count
        }
    }
    
    override init() {
        super.init()
    }
    
    
    func items() -> [LKCountdownItem]! {
        return self.model.items
    }
    
    func reload() {
        self.model.reloadItems()
    }
    
    func startUpdates() {
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    
    func endUpdates() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }
    
    func update() {
        /*
        for object in self.items {
            let index = self.items.indexOfObject(object)
            //println("current update index: \(index)")
            
            let item: LKCountdownItem = object as LKCountdownItem
            item.updateTimeRemaining()
            
            self.items.replaceObjectAtIndex(index, withObject: item)
        }
        
        self.updateCompletionClosure()
*/
    }
    
    
    func saveNewCountdownItem(item: LKCountdownItem) {
        self.model.saveNewItem(item)
        println("did succed saving the item")
        self.didAddNewItemConpletionClosure()

    }
    
    func deleteCountdownItem(item: LKCountdownItem) {
        self.model.deleteItem(item)
    }
    
    
    
}

class LKCountdownItem: NSObject {
    
    let name: String!
    let date: NSDate!
    let id: String!
    
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
    
    init(name: String, date: NSDate) {
        self.name = name
        self.date = date
        let uuid = NSUUID().UUIDString
        println("uuid used for saving: \(uuid)")
        self.id = uuid
    }
    
    init(object: NSManagedObject) {
        self.name = object.valueForKey(coreDataNameKey) as String
        self.date = object.valueForKey(coreDataDateKey) as NSDate
        self.managedObject = object;
    }
    
    init(cloudRecord: CKRecord) {
        println("input cloudRecord: \(cloudRecord)")
        
        self.name = cloudRecord.valueForKey(countdownItemRecordNameKey) as String
        self.date = cloudRecord.valueForKey(countdownItemRecordDateKey) as NSDate
        self.id = cloudRecord.valueForKey(countdownItemRecordIdKey) as String
    }
    
    
    func updateTimeRemaining() {
        
        let calendar = NSCalendar.currentCalendar()
        
        let unitFlags = NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
        let components: NSDateComponents = calendar.components(unitFlags, fromDate: NSDate(), toDate: self.date, options: nil)
        
        self.remaining.days = components.day
        self.remaining.hours = components.hour
        self.remaining.minutes = components.minute
        self.remaining.seconds = components.second
        self.remaining.asString = "\(self.remaining.days) : \(self.remaining.hours) : \(self.remaining.minutes): \(self.remaining.seconds)"
        
    }
    
    // TODO: calculate the current time for updating at the same time for all items. A way to achive this would be to add a manager property to all items and then add a time property to the manager, the time propetzy of teh manager would be updated at teh beginning of each update cycle (in the maneger class)
}

extension LKCountdownItem {
    func isEqualToCountdownItem(item: LKCountdownItem) -> Bool {
        return self.id == item.id
    }
}

