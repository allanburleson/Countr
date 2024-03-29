//
//  LKModel.swift
//  Countr
//
//  Created by Lukas Kollmer on 22/12/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit


let countdownItemRecordType = "Item"
let countdownItemRecordNameKey = "Title"
let countdownItemRecordDateKey = "Date"
let countdownItemRecordIdKey = "id"


let coreDataEnitiyNameKey = "Item"
let coreDataTitleKey = "name"
let coreDataDateKey = "date"
let coreDataIdKey = "id"
let coreDataKindKey = "kind"
let coreDataKindDateKey = "date"
let coreDataKindDateAndTimeKey = "dateAndTime"
let coreDataKindUnknownKey = "unknown"

let didAddNewItemsSinceLastCloudSyncKey = "didAddNewItemsSinceLastCloudSync"

let modelDidLoadItemsKey = "modelDidLoadItems"

public let refreshUIKey = "refreshUI"



class LKModel {
    
    class var sharedInstance : LKModel {
        struct Static {
            static let instance : LKModel = LKModel()
        }
        return Static.instance
    }
    
    
    
    //private let privateDatabase: CKDatabase
    
    /**
    The countdown items loaded from the CoreData model
    */
    private(set) var items: [LKCountdownItem] = []
    
    /**
    The raw countdown items loaded from the CoreData model (all as NSManagedObject)
    */
    private var rawItems: [NSManagedObject] = []
    
    private var modelChangedAction: () -> () = {}
    
    //private(set) var managedObjectContext: NSManagedObjectContext
    
    
    
    
    init() {

        self.modelChangedAction = {
            self.saveDataForExtension()
        }
        
        self.loadData(completionHandler: nil)
        
        //self.privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
        
        //self.loadData()
        //self.syncData()
        //self.subscribeToNewContent()
        
    }
    
    
    /*
    Note: the commented out code at the bottom of this file should be inserted at this position
    */

    
    /**
    Load the countdownItems from the CoreData model
    
    - parameter completionHandler: A closure which is executed when all items have been loadad
    */
    private func loadData(completionHandler completionHandler: (() -> Void)?) {
        
        let managedObjectContext: NSManagedObjectContext = self.managedObjectContext!
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let entity = NSEntityDescription.entityForName(coreDataEnitiyNameKey, inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        let error = NSErrorPointer()
        let fetchedItems: NSArray = (try! managedObjectContext.executeFetchRequest(fetchRequest)) as NSArray
        let _rawItems: NSArray = fetchedItems.reverseObjectEnumerator().allObjects
        if (error != nil) {
        } else {
            self.items = [] // This is nexccessary in order to clear the array, otherwise, after each reload (eg after adding/deleting, there would be each item multiple times
            self.rawItems = []
            for object in _rawItems {
                let managedObject: NSManagedObject = object as! NSManagedObject
                //println("the managedobject that will be used for adding to the local data meant for being displayed: \(managedObject)")
                let cdItem = LKCountdownItem(object: managedObject)
                self.items.append(cdItem)
                
                self.rawItems.append(managedObject)
            }
            
            sortArray()
            
            //println("the local data: \(self.items)")
        }

        modelChangedAction()
        completionHandler?()
    }
    
    /**
    Sorts both arrays (self.items and self.rawItems) by the sorting style selected in settings
    
    -  Date: Sort by timeInterval since the reference date (the newest items are on top)
    -  Title: Sort by the title of the countdownItem (alphabetically)
    */
    private func sortArray() {
        switch LKSettingsManager.sharedInstance.sortingStyle {
        case .Date:
            self.items.sortInPlace    { $0.date.timeIntervalSinceNow < $1.date.timeIntervalSinceNow}
            self.rawItems.sortInPlace { ($0.valueForKey(coreDataDateKey) as! NSDate).timeIntervalSinceNow < ($1.valueForKey(coreDataDateKey) as! NSDate).timeIntervalSinceNow}
        case .Title:
            self.items.sortInPlace    { $0.title.localizedCaseInsensitiveCompare($1.title) == NSComparisonResult.OrderedAscending }
            self.rawItems.sortInPlace { ($0.valueForKey(coreDataTitleKey) as! String).localizedCaseInsensitiveCompare(($1.valueForKey(coreDataTitleKey) as! String)) == NSComparisonResult.OrderedAscending}
        }
    }
    
    /*
    Share an item
    
    */
    func shareItem(item: LKCountdownItem, completionHandler: ((shareText: String, fileURL: NSURL) -> Void)?) {
    }
    
    /**
    Save a new countdown item to the model
    
    - parameter item: The countdown item to be saved
    */
    func saveNewItem(item: LKCountdownItem) {
        
        let context = self.managedObjectContext!
        let object: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(coreDataEnitiyNameKey, inManagedObjectContext: context) 
        object.setValue(item.title, forKey: coreDataTitleKey)
        object.setValue(item.date, forKey: coreDataDateKey)
        object.setValue(item.id, forKey: coreDataIdKey)
        object.setValue(item.countdownMode.toString(), forKey: coreDataKindKey)
        let saveError = NSErrorPointer()
        do {
            try context.save()
        } catch let error as NSError {
            saveError.memory = error
        }
        if !(saveError != nil) {
            //println("locally saved!")
            self.items.append(item)
            self.rawItems.append(object)
            self.sortArray()
            modelChangedAction()
            
        } else {
            //println("error saving locally")
        }
        
    }
    
    
    /*//TODO: Add description*/
    func updateItem(oldItem: LKCountdownItem, withItem newItem: LKCountdownItem, completionHandler: (() -> Void)?) {
        
        
        self.deleteItem(oldItem)
        self.saveNewItem(newItem)
        
        
        saveContext()
        
        completionHandler?()

    }
    
    /**
    Delete a countdown Item
    
    - parameter item: The countdown item to be deleted
    */
    func deleteItem(item: LKCountdownItem) {
        
        let index: Int = self.items.indexOf(item)!
        
        let _tempItemManagedObject: NSManagedObject = self.rawItems[index] as NSManagedObject
        let _tempItemID: String = _tempItemManagedObject.valueForKey(coreDataIdKey) as! String
        
        assert(_tempItemID == item.id, "_tempItemID == item.id")
        //println("Will delet item at index: \(index) itemDescription: \(item)")
        
        self.items.removeAtIndex(index)
        self.rawItems.removeAtIndex(index)
        print("self.managedObjectContext!: \(self.managedObjectContext!)")
        print("item.managedObject: \(item.managedObject)")
        self.managedObjectContext!.deleteObject(_tempItemManagedObject)
        
        let error: NSErrorPointer = NSErrorPointer()
        // Save the object to persistent store
        do {
            try self.managedObjectContext!.save()
            //println("Did sucessfully delete the item at index \(index)")
        } catch let error1 as NSError {
            error.memory = error1
            //println("Can't delete: \(error), \(error.debugDescription)")
        }
        
        reloadItems()
        modelChangedAction()
    }

    /**
    Reload all items from the CoreData model
    */
    func reloadItems() {
        self.loadData(completionHandler: nil)
    }
    
    /**
    Delete all countdown items currently stored in the CoreData model
    
    - parameter completionHandler: A closure which is executed when all items were deleted sucessfully
    */
    func deleteAllItems(completionHandler completionHandler: (success: Bool) -> ()) {
        let moc = self.managedObjectContext!
        for object in self.rawItems {
            moc.deleteObject(object)
        }
        let error: NSErrorPointer = NSErrorPointer()
        do {
            try moc.save()
            //println("Sucessfully deleted all items")
            modelChangedAction()
            completionHandler(success: true)
        } catch let error1 as NSError {
            error.memory = error1
            //println("Error: \(error.debugDescription)")
            completionHandler(success: false)
        }
    }
    
    
    // MARK: - CoreData + iCloud (from AppDelegate)
    
    // MARK: iCloud support
    
    /**
    The iCloud CoreData settings
    
    - returns: A Dictionary containing the required options
    */
    private func iCloudPersistentStoreOptions() -> [NSObject : AnyObject] {
        //println("iCloudPersistentStoreOptions")
        return [NSPersistentStoreUbiquitousContentNameKey : "CountrStore"]
    }
    
    /**
    The function paired with the storesWillChange Notification
    */
    func storesWillChange(notification: NSNotification) {
        //println("storesWillChange")
        let context = self.managedObjectContext
        
        context?.performBlockAndWait({
            var error: NSError? = nil
            
            if (context?.hasChanges != nil) {
                let success: Bool!
                do {
                    try context?.save()
                    success = true
                } catch let error1 as NSError {
                    error = error1
                    success = false
                } catch {
                    fatalError()
                }
                
                if (!success && error != nil) {
                    //println("Error: \(error?.localizedDescription)")
                }
            }
            
            context?.reset()
        })
        //TODO: Refresh your User Interface.
        refreshUI()
    }
    
    /**
    The function paired with the storesDidChange Notification
    */
    func storesDidChange(notification: NSNotification) {
        //println("storesDidChange")
        //TODO: Refresh your User Interface.
        refreshUI()
    }
    
    /**
    The function paired with the persistentStoreDidImportUbiquitousContentChanges Notification
    */
    func persistentStoreDidImportUbiquitousContentChanges(changeNotification: NSNotification) {
        //println("persistentStoreDidImportUbiquitousContentChanges")
        let context = self.managedObjectContext
        
        context?.performBlock({
            context?.mergeChangesFromContextDidSaveNotification(changeNotification)
            return //This is needed, otherwise complains teh compiler
        })
        refreshUI()
    }
    
    /**
    Send a notification to the whole app to reload the UI
    */
    private func refreshUI() {
        NSNotificationCenter.defaultCenter().postNotificationName(refreshUIKey, object: nil)
    }
    
    // MARK: - Core Data stack
    
    /**
    The application Documents directory
    */
    lazy private var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "WL6ZJ4C8V3.me.kollmer.Countr" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    /**
    The applications managedObjectModel
    */
    lazy private var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Countr", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    /**
    The applications persistentStoreCoordinator
    */
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Countr.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        var options: [NSObject : AnyObject]? = nil
        options = self.iCloudPersistentStoreOptions()
        
        //println("did purchase sync: \(LKPurchaseManager.didPurchase), options: \(options)")
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict: [NSObject : AnyObject] = [:]
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    /**
    The applicationf managedObjectContext
    */
    lazy private var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    /**
    Save the current CoreData context
    */
    func saveContext () {
        
        modelChangedAction()
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    /**
    Save the countdown items to the Today Extension
    */
    func saveDataForExtension() {
        let extensionDataManager = LKSharedExtensionDataManager()
        extensionDataManager.saveCountdownItemsToExtension(self.items)
        
        //println("data saved to extension: \(self.items)")
        //println("data resd from extension: \(extensionDataManager.loadCountdownItemsForExtension())")
    }    
    
}




extension CKRecord {
    
    /**
    Create a CKRecord object from a countdown item
    
    - parameter item: The Countdown item to be used for creating the record
    
    - returns: A CKRecord created from the passed countdown item
    */
    class func recordFromCountdownItem(item: LKCountdownItem) -> CKRecord {
        let record = CKRecord(recordType: countdownItemRecordType)
        record.setValue(item.title, forKey: countdownItemRecordNameKey)
        record.setValue(item.date, forKey: countdownItemRecordDateKey)
        record.setValue(item.id, forKey: countdownItemRecordIdKey)
        
        return record
    }
}


extension CKErrorCode {
    
    func toString() -> String {
        switch self {
        case .InternalError:
            return "InternalError: CloudKit encountered an error. This is a non-recoverable error."
        case .PartialFailure:
            return "PartialFailure: Some items failed but the operation succeeded overall."
        case .NetworkUnavailable:
            return "NetworkUnavailable: The network is not available."
        case .NetworkFailure:
            return "NetworkFailure: The network was available but returned an error during access."
        case .BadContainer:
            return "BadContainer: The specified container is unknown or unauthorized."
        case .ServiceUnavailable:
            return "ServiceUnavailable: The CloudKit service is unavailable."
        case .RequestRateLimited:
            return "RequestRateLimited: Transfers to and from the server are being rate limited for the client at this time."
        case .MissingEntitlement:
            return "MissingEntitlement: The app is missing a required entitlement."
        case .NotAuthenticated:
            return "NotAuthenticated: The current user is not authenticated and no user record was available. This might happen if the user is not logged into iCloud."
        case .PermissionFailure:
            return "PermissionFailure: The user did not have permission to perform the specified save or fetch operation."
        case .UnknownItem:
            return "UnknownItem: The specified record does not exist."
        case .InvalidArguments:
            return "InvalidArguments: The specified request contained bad information, perhaps because of a bad record graph or a malformed predicate."
        case .ResultsTruncated:
            return "ResultsTruncated: Query results were truncated by the server."
        case .ServerRecordChanged:
            return "ServerRecordChanged: The record was rejected because the version on the server was different."
        case .ServerRejectedRequest:
            return "ServerRejectedRequest: The server rejected this request. This is a non-recoverable error."
        case .AssetFileNotFound:
            return "AssetFileNotFound: The specified asset file was not found."
        case .AssetFileModified:
            return "AssetFileModified: The specified asset file content was modified while being saved."
        case .IncompatibleVersion:
            return "IncompatibleVersion: The app version is less than the minimum allowed version."
        case .ConstraintViolation:
            return "ConstraintViolation: The server rejected the request because there was a conflict with a unique field."
        case .OperationCancelled:
            return "OperationCancelled: A CKOperation object was explicitly cancelled."
        case .ChangeTokenExpired:
            return "ChangeTokenExpired: The previousServerChangeToken value is too old and the client must re-sync from scratch."
        case .BatchRequestFailed:
            return "BatchRequestFailed: One of the items in this batch operation failed in a zone with atomic updates, so the entire batch was rejected."
        case .ZoneBusy:
            return "ZoneBusy: The server is too busy to handle this zone operation. Try the operation again in a few seconds. If you encounter this error again, increase the delay time exponentially for each subsequent retry to minimize server contention for the zone."
        case .BadDatabase:
            return "BadDatabase: The operation could not be completed on the given database. This problem was likely caused by attempting to modify zones in a public database."
        case .QuotaExceeded:
            return "QuotaExceeded: Saving the record would exceed the user’s current storage quota."
        case .ZoneNotFound:
            return "ZoneNotFound: The specified record zone does not exist on the server."
        case .LimitExceeded:
            return "LimitExceeded: The request to the server was too large. Try refactoring your request into multiple smaller batches."
        case .UserDeletedZone:
            return "UserDeletedZone: The user deleted this zone from the settings UI. Remove your local copy of the zone’s data or ask the user if you should upload the data again."
        }
    }
}


/*

IMPORTANT NOTE: The whole shit below works just fine - except for CloudKit. There are some problems which I try to fix by using CoreData in iCloud instead of CloudKit.

Problems:
- Offline Saving (could be fixes easily be comparing the list of local data to the list of remote data)
- Offline Editing (harder to make working)
- Offline deleting (nearly im possible)
- Having multiple items added from multiple devices (??First rules??)


func subscribeToNewContent() {
let predicate = NSPredicate(value: true)

let subscription = CKSubscription(recordType: countdownItemRecordType, predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)

let notificationInfo = CKNotificationInfo()
notificationInfo.alertBody = ""
notificationInfo.shouldBadge = true

subscription.notificationInfo = notificationInfo

self.privateDatabase.saveSubscription(subscription, completionHandler: { (subscription: CKSubscription!, error: NSError!) -> Void in
//println("THE SUBSCRIPTION FIRED")
})

}


func saveNewItem(item: LKCountdownItem) {
let record = CKRecord.recordFromCountdownItem(item)
self.privateDatabase.saveRecord(record, completionHandler: {record, error in
//println("save record error: \(error)")
if !(error != nil) {
//println("saving to the cloud succeded")
} else {
//println("saving to teh cloud was not possible, save locally")
let context = self.managedObjectContext()
let object: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(coreDataEnitiyNameKey, inManagedObjectContext: context) as NSManagedObject
object.setValue(item.name, forKey: coreDataNameKey)
object.setValue(item.date, forKey: coreDataDateKey)
let saveError = NSErrorPointer()
context.save(saveError)
if !(saveError != nil) {
//println("locally saved!")
NSUserDefaults.standardUserDefaults().setBool(true, forKey: didAddNewItemsSinceLastCloudSyncKey)
} else {
//println("error saving locally")
}
}
})

self.loadData()

}



// MARK: CoreData

func managedObjectContext() -> NSManagedObjectContext {
var context: NSManagedObjectContext?
var delegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
context = delegate.managedObjectContext
return context!
}

// MARK: MAIN THING
func loadData() {



let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: countdownItemRecordType, predicate: predicate)
self.privateDatabase.performQuery(query, inZoneWithID: nil) { results, error in
if error != nil {
dispatch_async(dispatch_get_main_queue()) {
//println("error: \(error)")
//println("Loading CloudKit data failed, will now load local data")
//self.errorUpdating(error)
//self.loadingCloudDataFailed()
self.loadLocalData()
return
}
} else {
self.items.removeAll(keepCapacity: true)
for record in results{
let cdItem = LKCountdownItem(cloudRecord: record as CKRecord)
self.items.append(cdItem)
//println("did append item")

}
dispatch_async(dispatch_get_main_queue()) {
//self.modelUpdated()
//_error = nil
//println("inner array.count: \(self.items.count)")
self.didSucceedLoadingCloudItems()
return
}
}
}

}
/*
NOTE: There are thwo separate functions needed for these two things (finishing loading local and cloud data) because new items may be uploaded after loading the clouditems
*/

func didSucceedLoadingCloudItems() {
//println("didSucceedLoadingCloudItemsssss array.count: \(self.items.count)")
NSNotificationCenter.defaultCenter().postNotificationName(modelDidLoadItemsKey, object: nil)

self.resolveDataConflicts()
}

func didSucceedLoadingLocalItems() {

}



/*
func loadCloudKitData() {


let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: countdownItemRecordType, predicate: predicate)
self.privateDatabase.performQuery(query, inZoneWithID: nil) { results, error in
if error != nil {
dispatch_async(dispatch_get_main_queue()) {
//println("error: \(error)")
//self.errorUpdating(error)
return
}
} else {
self.items.removeAll(keepCapacity: true)
for record in results{
let cdItem = LKCountdownItem(cloudRecord: record as CKRecord)
self.items.append(cdItem)
//println("did append item")
//println("inner array.count: \(self.items.count)")

}
dispatch_async(dispatch_get_main_queue()) {
//self.modelUpdated()
//_error = nil
return
}
}
}

}
*/


func loadCloudKitDataToArray() -> [LKCountdownItem] {
//println("loadCloudKitDataToArray")

var tempItems: [LKCountdownItem] = []
let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: countdownItemRecordType, predicate: predicate)
self.privateDatabase.performQuery(query, inZoneWithID: nil) { results, error in
if error != nil {
dispatch_async(dispatch_get_main_queue()) {
return
}
} else {
dispatch_async(dispatch_get_main_queue()) {
tempItems.removeAll(keepCapacity: true)
for record in results{
let cdItem = LKCountdownItem(cloudRecord: record as CKRecord)
tempItems.append(cdItem)
}
return
}
}
}

//println("the cloud data to array: \(tempItems)")
return tempItems
}

private func modelUpdated() {
//println("teh fetched items: \(self.items)")
//println("number of items: \(self.items.count)")
//println("Should now save teh fetched data to the local coreData")

NSNotificationCenter.defaultCenter().postNotificationName(modelDidLoadItemsKey, object: nil)

self.cacheCloudItemsLocally()
//println("did replace the local coredata stack")

}



private func errorUpdating(error: NSError) {
//println("Error: \(error)")
}




func loadLocalData() {

let managedObjectContext: NSManagedObjectContext = self.managedObjectContext()
let fetchRequest: NSFetchRequest = NSFetchRequest()
fetchRequest.returnsObjectsAsFaults = false
let entity = NSEntityDescription.entityForName(coreDataEnitiyNameKey, inManagedObjectContext: managedObjectContext)
fetchRequest.entity = entity
var error = NSErrorPointer()
let fetchedItems: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: error)! as NSArray
let rawItems: NSArray = fetchedItems.reverseObjectEnumerator().allObjects
if (error != nil) {
} else {
self.items = []
for object in rawItems {
let managedObject: NSManagedObject = object as NSManagedObject
//println("the managedobject that will be used for adding to the local data meant for being displayed: \(managedObject)")
let cdItem = LKCountdownItem(object: managedObject)
self.items.append(cdItem)
}
//println("the local data: \(self.items)")
}
}


func loadLocalDataToArray() -> [LKCountdownItem] {
//println("loadLocalDataToArray")

let managedObjectContext: NSManagedObjectContext = self.managedObjectContext()
let fetchRequest: NSFetchRequest = NSFetchRequest()
fetchRequest.returnsObjectsAsFaults = false
let entity = NSEntityDescription.entityForName(coreDataEnitiyNameKey, inManagedObjectContext: managedObjectContext)
fetchRequest.entity = entity
var error = NSErrorPointer()
let fetchedItems: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: error)! as NSArray
let rawItems: NSArray = fetchedItems.reverseObjectEnumerator().allObjects

var _items: [LKCountdownItem] = []

for object in rawItems {
let managedObject: NSManagedObject = object as NSManagedObject
let cdItem = LKCountdownItem(object: managedObject)
_items.append(cdItem)
}

//println("the local data to array: \(_items)")
return _items
}

func resolveDataConflicts() {

//println("RESOLVE_DATA_CONFLICTS")

let _localItems = self.loadLocalDataToArray()
let cloudItems = self.loadCloudKitDataToArray()

if _localItems.count != cloudItems.count {
//println("some items have been added or deleted (local.count: \(_localItems.count), cloud.count: \(cloudItems.count))")
}
if NSUserDefaults.standardUserDefaults().boolForKey(didAddNewItemsSinceLastCloudSyncKey) {
//println("should now upload all recently added items")
//println("will now upload")
let _localItems = self.loadLocalDataToArray()
let localItems: NSMutableArray = NSMutableArray(array: _localItems)
let cloudItems = self.loadCloudKitDataToArray()

//println("the arrays:localItems: \(localItems) _localitems\(_localItems) cloudItems: \(cloudItems)")
for localObject in _localItems {
//println("in 1st for loop")
for cloudObject in cloudItems {
//println("in 2nd for loop")
if cloudObject.id == localObject.id {
//println("in if clause")
//println("array before removing object: \(localItems)")
localItems.removeObject(localObject)
//println("array after removing object: \(localItems)")
}
}
}

//println("all remaining items: \(localItems)")
for object in localItems {
let item: LKCountdownItem = object as LKCountdownItem
self.saveNewItem(item)
//println("did save item with id \(item.id) to cloud")
}
NSUserDefaults.standardUserDefaults().setBool(false, forKey: didAddNewItemsSinceLastCloudSyncKey)
} else {
//println("everything is up to date. Tehere is no need to do anything")
}

}

func syncData() {
let _localItems = self.loadLocalDataToArray()
let cloudItems = self.loadCloudKitDataToArray()

if _localItems.count != cloudItems.count {
//println("some items have been added or deleted (local.count: \(_localItems.count), cloud.count: \(cloudItems.count))")
}
if NSUserDefaults.standardUserDefaults().boolForKey(didAddNewItemsSinceLastCloudSyncKey) {
//println("should now upload all recently added items")
if Reachability.isConnectedToNetwork() {
//println("will now upload")
let _localItems = self.loadLocalDataToArray()
let localItems: NSMutableArray = NSMutableArray(array: _localItems)
let cloudItems = self.loadCloudKitDataToArray()

//println("the arrays:localItems: \(localItems) _localitems\(_localItems) cloudItems: \(cloudItems)")
for localObject in _localItems {
//println("in 1st for loop")
for cloudObject in cloudItems {
//println("in 2nd for loop")
if cloudObject.id == localObject.id {
//println("in if clause")
//println("array before removing object: \(localItems)")
localItems.removeObject(localObject)
//println("array after removing object: \(localItems)")
}
}
}

//println("all remaining items: \(localItems)")
for object in localItems {
let item: LKCountdownItem = object as LKCountdownItem
self.saveNewItem(item)
//println("did save item with id \(item.id) to cloud")
}
self.loadData()
NSUserDefaults.standardUserDefaults().setBool(false, forKey: didAddNewItemsSinceLastCloudSyncKey)
}
} else {
//println("everything is up to date. Tehere is no need to do anything")
self.loadData()
}
}


func saveNewCountdownItem(item: LKCountdownItem) -> (success: Bool, error: NSErrorPointer){
//println("saving is currently disabled, due to implementing cloudkit")
return (false, nil)
}


func saveCountdownItemsToLocalCoreData() {
}


func saveLocalCoreDataCountdownItemsToCloudKit() {
self.loadData()
for item in self.items {
let record: CKRecord = CKRecord.recordFromCountdownItem(item as LKCountdownItem)
self.saveNewItem(item)
}
}

func cacheCloudItemsLocally() {

// Delete all local items
let managedObjectContext: NSManagedObjectContext = self.managedObjectContext()
let fetchRequest: NSFetchRequest = NSFetchRequest()
fetchRequest.returnsObjectsAsFaults = false
let entity = NSEntityDescription.entityForName(coreDataEnitiyNameKey, inManagedObjectContext: managedObjectContext)
fetchRequest.entity = entity
var error = NSErrorPointer()
let fetchedItems: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: error)! as NSArray
let rawItems: NSArray = fetchedItems.reverseObjectEnumerator().allObjects
//println("moc before deleting: \(rawItems)")

for object in rawItems {
managedObjectContext.deleteObject(object as NSManagedObject)
}
managedObjectContext.save(error)


let _2fetchedItems: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: error)! as NSArray
let _2rawItems: NSArray = fetchedItems.reverseObjectEnumerator().allObjects
//println("moc after deleting: \(_2rawItems)")



// Save the cloud items
for item in self.items {
let object: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(coreDataEnitiyNameKey, inManagedObjectContext: managedObjectContext) as NSManagedObject
object.setValue(item.name, forKey: coreDataNameKey)
object.setValue(item.date, forKey: coreDataDateKey)
object.setValue(item.id, forKey: countdownItemRecordIdKey)
managedObjectContext.save(error)
}
//managedObjectContext.save(error)
let _3fetchedItems: NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error: error)! as NSArray
let _3rawItems: NSArray = fetchedItems.reverseObjectEnumerator().allObjects
//println("moc after saving the cloud items: \(_3rawItems)")

}
*/


