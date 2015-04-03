//
//  LKSettingsManager.swift
//  Countr
//
//  Created by Lukas Kollmer on 4/3/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation

public let settingsDidChangeNotficationKey = "settingsDidChangeNotification"

internal typealias LKSettingsConfiguration = [String : AnyObject]

internal let appBadgeKey: String = "displaysAppBadge"
internal let sortingStyleKey: String = "sortingStyle"

class LKSettingsManager {
    class var sharedInstance : LKSettingsManager {
        struct Static {
            static let instance : LKSettingsManager = LKSettingsManager()
        }
        return Static.instance
    }
    
    var localFilePath: String {
        return NSBundle.mainBundle().pathForResource("settings", ofType: "plist")!
    }
    

    var documentsDirFilePath: String {
        let documentsDirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return documentsDirPath.stringByAppendingPathComponent("settings.plist")
    }
    
    
    private(set) var sortingStyle: LKSortingStyle = .Date
    
    private(set) var appBadgeEnabled: Bool = true
    
    
    
    init() {

        copyRessourceFileToDocumentdDirectory()
        let _settingsConfiguration = self.loadSettingsConfigurationRawDataFromFile()
        
        
        if let _sortingStyleRawString = _settingsConfiguration[sortingStyleKey] as? String {
            self.sortingStyle = LKSortingStyle.styleFromString(_sortingStyleRawString)
        }
        
        if let _appBadgeEnabled = _settingsConfiguration[appBadgeKey] as? Bool {
            self.appBadgeEnabled = _appBadgeEnabled
        }
        
    }
    
    
    
    func setSortingStyle(sortingStyle: LKSortingStyle) {
        self.sortingStyle = sortingStyle
        
        settingsChanged()
    }
    
    func setAppBadgeOn(badgeOn: Bool) {
        self.appBadgeEnabled = badgeOn
        
        settingsChanged()
    }
    
    private func settingsChanged() {
        let settingsConfiguration = [
            appBadgeKey     : self.appBadgeEnabled,
            sortingStyleKey : self.sortingStyle.toString()
        ]
        self.saveSettingsConfigurationToFile(settingsConfiguration)
        NSNotificationCenter.defaultCenter().postNotificationName(settingsDidChangeNotficationKey, object: nil)
    }
    
    // MARK: Load settings
    
    /**
    Load the settings configuration
    
    :returns: The Apps settings configutation
    */
    private func loadSettingsConfigurationRawDataFromFile() -> LKSettingsConfiguration {
        
        return NSDictionary(contentsOfFile: documentsDirFilePath)! as LKSettingsConfiguration
    }
    
    // MARK: Save settings
    
    private func saveSettingsConfigurationToFile(data: LKSettingsConfiguration) {
        
        
        NSDictionary(dictionary: data).writeToFile(documentsDirFilePath, atomically: true)
    }

    
    // MARK: File management
    
    /**
    Copy the default plist file from the app bundle to the shared container.
    
    This should happen only once, after the file has been copied once, it won't be copied again
    */
    private func copyRessourceFileToDocumentdDirectory() {
        // Copy the plist file containinf the data for the extension
        
        var error: NSErrorPointer = nil
        
        println("bundle dir: \(localFilePath)")
        println("documents dir \(documentsDirFilePath)")
        
        
        if !NSFileManager.defaultManager().fileExistsAtPath(documentsDirFilePath) {
            //println("file dies not exist, copy")
            NSFileManager.defaultManager().copyItemAtPath(localFilePath, toPath:documentsDirFilePath, error: error)
            
            //println("did copy file. error: \(error.debugDescription)")
        }
        
    }

}


enum LKSortingStyle {
    case Title
    case Date
    
    internal static func styleFromString(string: String) -> LKSortingStyle {
        switch string {
        case "date":
            return .Date
        case "title":
            return .Title
        default:
            return .Date
        }
    }
    
    init(index: Int) {
        switch index {
        case 0:
            self = .Title
        case 1:
            self = .Date
        default:
            self = .Date
        }
    }
    
    internal func toString() -> NSString {
        switch self {
        case .Date:
            return "date"
        case .Title:
            return "title"
        }
    }
    
    func toIndex() -> Int {
        switch self {
        case .Title:
            return 0
        case .Date:
            return 1
        }
    }
}