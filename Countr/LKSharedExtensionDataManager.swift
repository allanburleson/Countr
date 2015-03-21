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
    
    func filePathForDocumentsDirectory() -> String {
        let fileManager = NSFileManager.defaultManager()
        let containerURL = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.me.kollmer.Countr")!
        let containerURLPath = containerURL.path!
        let filePath = containerURLPath.stringByAppendingPathComponent("extensionData.plist")
        
        return filePath
    }

    func filePathForApplicationBundle() -> String {
        return NSBundle.mainBundle().pathForResource("extensionData", ofType: "plist")!
    }
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
        var itemsForExtension: [LKCountdownItem] = []
        println("0")
        if items.count < 3 {
            println("1")
            itemsForExtension = items
            println("2")
        } else {
            println("3")
            itemsForExtension = Array(items[0...2])
            println("4")
        }
        println("5")
        
        var extensionData: LKExtensionData = []
        println("6")
        for item in itemsForExtension {
            println("7")
            extensionData.append([
                title_key : item.name,
                date_key : item.date,
                id_key : item.id,
                mode_key : item.countdownMode.toString()
                ])
            println("8")
        }
        println("9")

        println("10")
        println("array for today extension: \(itemsForExtension)")
        println("11")
        println("sorted data for today extension: \(extensionData)")
        println("12")

        println("13")
        saveDataToExtensionDataFile(extensionData)
        println("14")
    }
    
    
    
    private func loadDataFromExtensionDataFile() -> LKExtensionData {
        let _arrayBridgedToNSArray: NSArray = NSArray(contentsOfFile: filePathForDocumentsDirectory())!
        
        println("array read from file: \(_arrayBridgedToNSArray)")
        
        return _arrayBridgedToNSArray.objectEnumerator().allObjects as LKExtensionData
    }
    
    private func saveDataToExtensionDataFile(data: LKExtensionData) {

        println("15")
        let _arrayBridgedToNSArray: NSArray = NSArray(array: data)

        println("16")
        _arrayBridgedToNSArray.writeToFile(filePathForDocumentsDirectory(), atomically: true)
        println("17")
    }
    
    
    
    // MARK: File management
    
    private func copyRessourceFileToDocumentdDirectory() {
        // Copy the plist file containinf the data for the extension
        
        var error: NSErrorPointer = nil
        
        if !NSFileManager.defaultManager().fileExistsAtPath(filePathForDocumentsDirectory()) {
            println("file dies not exist, copy")
            NSFileManager.defaultManager().copyItemAtPath(filePathForApplicationBundle(), toPath:filePathForDocumentsDirectory(), error: error)
            
            println("did copy file. error: \(error.debugDescription)")
        }

    }
}