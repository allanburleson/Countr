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
The class that manages the countdown data which is shared between the main app and the extension
*/
class LKSharedExtensionDataManager {
    
    /**
    The file path for the extension data file in the applications shared container
    
    :returns: A String representing the file Path
    */
    private func filePathForSharedContainer() -> String {
        let fileManager = NSFileManager.defaultManager()
        let containerURL = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.me.kollmer.Countr")!
        let containerURLPath = containerURL.path!
        let filePath = containerURLPath.stringByAppendingPathComponent("extensionData.plist")
        
        return filePath
    }

    /**
    The file path for the extension data file in the applications main bundle
    
    :returns: A String representing the file Path
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
    
    :returns: An Array containing 0-3 countdown items
    */
    func loadCountdownItemsForExtension() -> [LKCountdownItem] {
        let data: LKExtensionData = self.loadDataFromExtensionDataFile()
        
        var countdownItems: [LKCountdownItem] = []
        
        for item in data {
            let title:        String = item[title_key] as String
            let date:         NSDate = item[date_key]  as NSDate
            let id:           String = item[id_key]    as String
            let modeAsString: String = item[mode_key]  as String
            
            let mode = LKCountdownMode(string: modeAsString)
            let uuid = NSUUID(UUIDString: id)!
            
            let countdownItem = LKCountdownItem(name: title, date: date, mode: mode, id: uuid)
            
            countdownItems.append(countdownItem)
        }
        
        return countdownItems
    }
    
    /**
    Save the countdown items used in the extension
    
    :param: items An Array containing the items that should be saved
    */
    func saveCountdownItemsToExtension(items: [LKCountdownItem]) {
        var itemsForExtension: [LKCountdownItem] = []
        //println("0")
        if items.count < 3 {
            //println("1")
            itemsForExtension = items
            //println("2")
        } else {
            //println("3")
            itemsForExtension = Array(items[0...2])
            //println("4")
        }
        //println("5")
        
        var extensionData: LKExtensionData = []
        //println("6")
        for item in itemsForExtension {
            //println("7")
            extensionData.append([
                title_key : item.name,
                date_key : item.date,
                id_key : item.id,
                mode_key : item.countdownMode.toString()
                ])
            //println("8")
        }
        //println("9")

        //println("10")
        //println("array for today extension: \(itemsForExtension)")
        //println("11")
        //println("sorted data for today extension: \(extensionData)")
        //println("12")

        //println("13")
        saveDataToExtensionDataFile(extensionData)
        //println("14")
    }
    
    
    /**
    Read the extension data from the file
    
    :returns: An object of type LKExtensionData which is an array containing multiple dictionaries containg the items
    */
    private func loadDataFromExtensionDataFile() -> LKExtensionData {
        let _arrayBridgedToNSArray: NSArray = NSArray(contentsOfFile: filePathForSharedContainer())!
        
        //println("array read from file: \(_arrayBridgedToNSArray)")
        
        return _arrayBridgedToNSArray.objectEnumerator().allObjects as LKExtensionData
    }
    
    /**
    Save the extension data to the file
    
    :param: data An object of type LKExtensionData which is an array containing multiple dictionaries containg the items
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
        
        var error: NSErrorPointer = nil
        
        if !NSFileManager.defaultManager().fileExistsAtPath(filePathForSharedContainer()) {
            //println("file dies not exist, copy")
            NSFileManager.defaultManager().copyItemAtPath(filePathForApplicationBundle(), toPath:filePathForSharedContainer(), error: error)
            
            //println("did copy file. error: \(error.debugDescription)")
        }

    }
}