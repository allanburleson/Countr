//
//  LKSharedExtensionDataManager.swift
//  Countr
//
//  Created by Lukas Kollmer on 3/21/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation

private let title_key = "title" // String: the title of the countdown
private let date_key  = "date"  // NSDate: the reference date for the countdown
private let id_key    = "id"    // NSUUID: The id of the countdown. //TODO: Use this for opening the app from the extension. call a url seheme with teh id as parameter
private let mode_key  = "mode"  // LKCountdownMode: the mode used by the countdown: .Date/.DateAndTime

private typealias LKExtensionData = [[String : AnyObject]]

/**
An enum representing the four kinds of extensions that could access data from the shared container

Available values are:

-  TodayExtension
-  WatchApp
-  WatchGlance
-  WatchNotification
*/
enum LKExtensionType {
    /**
    The extension type Today Widget
    */
    case TodayExtension
    
    /**
    The extension type Watch App
    */
    case WatchApp
    
    /**
    The extension type Watch Glance
    */
    case WatchGlance
    
    /**
    The extension type Watch Notification
    */
    case WatchNotification
}

/**
The class that manages the countdown data which is shared between the main app and the extension
*/
class LKSharedExtensionDataManager {
    
    /**
    The file path for the extension data file in the applications shared container
    
    - returns: A String representing the file Path
    */
    private func filePathForSharedContainer() -> String {
        let fileManager = NSFileManager.defaultManager()
        let containerURL = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.me.kollmer.Countr")!
        let containerURLPath = containerURL.path!
        print("FILEPATHFILEPATHFILEPATH: \(containerURLPath)")
        let filePath = containerURLPath + "extensionData.plist"
        
        return filePath
    }

    /**
    The file path for the extension data file in the applications main bundle
    
    - returns: A String representing the file Path
    */
    private func filePathForApplicationBundle() -> String {
        return NSBundle.mainBundle().pathForResource("extensionData", ofType: "plist")!
    }
    
    init() {
        copyRessourceFileToDocumentdDirectory()
    }
    
    // MARK: Load & Save
    
    /**
    Load the countdown data for the extension
    
    - parameter type: A value of LKExtensionType representing the extension requesting the items
    
    - returns: An Array containing either 0-3 items (for today extension), two items (for watch glance) or all items (for watch app)
    */
    func loadCountdownItemsForExtensionWithType(type: LKExtensionType) -> [LKCountdownItem] {
        
        let data: LKExtensionData = self.loadDataFromExtensionDataFile()
        
        var countdownItems: [LKCountdownItem] = []
        
        for item in data {
            let title:        String = item[title_key] as! String
            let date:         NSDate = item[date_key]  as! NSDate
            let id:           String = item[id_key]    as! String
            let modeAsString: String = item[mode_key]  as! String
            
            let mode = LKCountdownMode(string: modeAsString)
            let uuid = NSUUID(UUIDString: id)!
            
            let countdownItem = LKCountdownItem(title: title, date: date, mode: mode, id: uuid)
            
            countdownItems.append(countdownItem)
        }
        
        var itemsForExtension: [LKCountdownItem] = []
        
        if type == .TodayExtension {
            if countdownItems.count < 3 {
                return countdownItems
            } else {
                return Array(countdownItems[0...2]) as [LKCountdownItem]
            }
        }
        
        if type == .WatchGlance {
            if countdownItems.count < 2 {
                return countdownItems
            } else {
                return Array(countdownItems[0...1]) as [LKCountdownItem]
            }
        }
        
        if type == .WatchApp {
            switch LKSettingsManager.sharedInstance.sortingStyle {
            case .Date:
                return countdownItems.sort {$0.date.timeIntervalSinceNow < $1.date.timeIntervalSinceNow}
            case .Title:
                return countdownItems.sort {$0.title.localizedCaseInsensitiveCompare($1.title) == NSComparisonResult.OrderedAscending}
            }
        }
        
        
        return countdownItems
    }
    
    /**
    Save the countdown items used in the extension
    
    - parameter items: An Array containing the items that should be saved
    */
    func saveCountdownItemsToExtension(items: [LKCountdownItem]) {
        var itemsForExtension: [LKCountdownItem] = []
        
        itemsForExtension = items
        
        
        var extensionData: LKExtensionData = []
        
        for item in itemsForExtension {
            extensionData.append([
                title_key : item.title,
                date_key : item.date,
                id_key : item.id,
                mode_key : item.countdownMode.toString()
                ])
        }

        //println("array for today extension: \(itemsForExtension)")
        //println("sorted data for today extension: \(extensionData)")
        saveDataToExtensionDataFile(extensionData)
    }
    
    
    /**
    Read the extension data from the file
    
    - returns: An object of type LKExtensionData which is an array containing multiple dictionaries containg the items
    */
    private func loadDataFromExtensionDataFile() -> LKExtensionData {
        let _arrayBridgedToNSArray: NSArray = NSArray(contentsOfFile: filePathForSharedContainer())!
        
        //println("array read from file: \(_arrayBridgedToNSArray)")
        
        return _arrayBridgedToNSArray.objectEnumerator().allObjects as! LKExtensionData
    }
    
    /**
    Save the extension data to the file
    
    - parameter data: An object of type LKExtensionData which is an array containing multiple dictionaries containg the items
    */
    private func saveDataToExtensionDataFile(data: LKExtensionData) {

        //println("15")
        let _arrayBridgedToNSArray: NSArray = NSArray(array: data)

        //println("16")
        _arrayBridgedToNSArray.writeToFile(filePathForSharedContainer(), atomically: true)
        //println("17")
    }
    
    
    
    // MARK: File management
    
    /**
    Copy the default plist file from the app bundle to the shared container.
    
    This should happen only once, after the file has been copied once, it won't be copied again
    */
    private func copyRessourceFileToDocumentdDirectory() {
        // Copy the plist file containinf the data for the extension
        
        let error: NSErrorPointer = nil
        
        if !NSFileManager.defaultManager().fileExistsAtPath(filePathForSharedContainer()) {
            do {
                //println("file dies not exist, copy")
                try NSFileManager.defaultManager().copyItemAtPath(filePathForApplicationBundle(), toPath:filePathForSharedContainer())
            } catch let error1 as NSError {
                error.memory = error1
            }
            
            //println("did copy file. error: \(error.debugDescription)")
        }

    }
}