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


class LKSharedExtensionDataManager {
    
    private let filePathForDocumentsDirectory: String = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String).stringByAppendingPathComponent("extensionData.plist")

    private let filePathForApplicationBundle = NSBundle.mainBundle().pathForResource("extensionData", ofType: "plist")!
    init() {
        copyRessourceFileToDocumentdDirectory()
    }
    
    // MARK: Load & Save
    
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
    
    func saveCountdownItemsToExtension(items: [LKCountdownItem]) {
        var itemsForExtension: [LKCountdownItem]
        if items.count < 3 {
            itemsForExtension = items
        } else {
            itemsForExtension = Array(items[0...3])
        }
        
        var extensionData: LKExtensionData = []
        for item in itemsForExtension {
            extensionData.append([
                title_key : item.name,
                date_key : item.date,
                id_key : item.id,
                mode_key : item.countdownMode.toString()
                ])
        }
        
        println("array for today extension: \(itemsForExtension)")
        println("sorted data for today extension: \(extensionData)")
        
        saveDataToExtensionDataFile(extensionData)
    }
    
    
    
    private func loadDataFromExtensionDataFile() -> LKExtensionData {
        let _arrayBridgedToNSArray: NSArray = NSArray(contentsOfFile: filePathForDocumentsDirectory)!
        
        println("array read from file: \(_arrayBridgedToNSArray)")
        
        return _arrayBridgedToNSArray.objectEnumerator().allObjects as LKExtensionData
    }
    
    private func saveDataToExtensionDataFile(data: LKExtensionData) {
        let _arrayBridgedToNSArray: NSArray = NSArray(array: data)
        
        _arrayBridgedToNSArray.writeToFile(filePathForDocumentsDirectory, atomically: true)
    }
    
    
    
    // MARK: File management
    
    private func copyRessourceFileToDocumentdDirectory() {
        // Copy the plist file containinf the data for the extension
        
        var error: NSErrorPointer = nil
        
        if !NSFileManager.defaultManager().fileExistsAtPath(filePathForDocumentsDirectory) {
            println("file dies not exist, copy")
            NSFileManager.defaultManager().copyItemAtPath(filePathForApplicationBundle, toPath:filePathForDocumentsDirectory, error: error)
            
            println("did copy file. error: \(error.debugDescription)")
        }

    }
}