//
//  AppDelegate.swift
//  Countr
//
//  Created by Lukas Kollmer on 30/11/14.
//  Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var model = LKModel.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let font = UIFont(name: "Avenir-Book", size: 17)!
        let titleTextAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // UILabel
        UILabel.appearance().font = font
        UILabel.appearance().textColor = UIColor.whiteColor()
        
        // UIButton
        UIButton.appearance().titleLabel?.font = UIFont(name: "Avenir-Book", size: 15)
        
        // UITableViewCell
        UITableViewCell.appearance().backgroundColor = UIColor.foregroundColor()
        
        // UICollectionView
        UICollectionView.appearance().backgroundColor = UIColor.backgroundColor()
        
        // UINavigationBar
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        // UIToolbar
        UIToolbar.appearance().barStyle = .Black
        UIToolbar.appearance().tintColor = UIColor.whiteColor()
        
        // UITextField
        UITextField.appearance().tintColor = UIColor.whiteColor()
        
        // UIBarButtonItem
        UIBarButtonItem.appearance().setTitleTextAttributes(titleTextAttributes, forState: UIControlState.Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(titleTextAttributes, forState: UIControlState.Highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes(titleTextAttributes, forState: UIControlState.Disabled)
        
        // UISegmentedControl
        let segmentedControlTitleTextAttributes: [NSObject : AnyObject] = [NSFontAttributeName : UIFont(name: "Avenir-Book", size: 13)!]
        UISegmentedControl.appearance().setTitleTextAttributes(segmentedControlTitleTextAttributes, forState: UIControlState.Normal)
        
        // UISwitch
        UISwitch.appearance().tintColor = UIColor.whiteColor()
        UISwitch.appearance().onTintColor = UIColor.whiteColor()
        UISwitch.appearance().thumbTintColor = UIColor.grayColor()
        
        // UIScrollView
        UIScrollView.appearance().indicatorStyle = .White
        
        
        
        application.registerForRemoteNotifications()
        
        

        let localNotificationSettings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        application.registerUserNotificationSettings(localNotificationSettings)
        
        setAppBadge()
        
        
        self.registerForiCloudNotifications()
        
        
        
        // Setup Google Analytics
        GAI.sharedInstance().trackUncaughtExceptions = true
        //GAI.sharedInstance().logger.logLevel = GAILogLevel.Verbose
        GAI.sharedInstance().trackerWithTrackingId("UA-49744076-4")
        
        
        // Setup background fetch
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // Setup crashlytics
        Crashlytics.startWithAPIKey("6d7126e3ca886ba0d9bf374db95cdcbbb0282302")
        
        return true
    }
    
    func setAppBadge() {
        if LKSettingsManager.sharedInstance.appBadgeEnabled {
            let countdownManager = LKCountdownManager.sharedInstance
            let numberOfItemsDueToday = countdownManager.itemsDueToday().count
            //println("numberOfItemsDueToday: \(numberOfItemsDueToday)")
            UIApplication.sharedApplication().applicationIconBadgeNumber = numberOfItemsDueToday
        }
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        //println("application(application:, performFetchWithCompletionHandler")
        
        /////////////////////////////////
        //      Duration Counting      //
        /////////////////////////////////
        
        // TODO: Remove this before submission
        //let startDate = NSDate()
        
        
        /////////////////////////////////
        // Save Data for the Extension //
        /////////////////////////////////
        
        let countdownManager = LKCountdownManager.sharedInstance
        countdownManager.saveDataForExtension()
        
        /////////////////////////////////
        //  Update Application Badge   //
        /////////////////////////////////
        
        setAppBadge()
        
        //println("abckgroundFetchEnded. Duration: \(startDate.timeIntervalSinceNow.positive) seconds")
        
        
        completionHandler(UIBackgroundFetchResult.NewData)
        
    }
    
    func registerForiCloudNotifications() {
        //println("registerForiCloudNotifications")
        let notificationCenter = NSNotificationCenter.defaultCenter()

        // CoreData
        notificationCenter.addObserver(self, selector: "storesWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.model.persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: "storesDidChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.model.persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: "persistentStoreDidImportUbiquitousContentChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: self.model.persistentStoreCoordinator)
        // Key/Value storing
        //notificationCenter.addObserver(self, selector: "", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: NSUbiquitousKeyValueStore.defaultStore())

    }
    
    func storesWillChange(notification: NSNotification) {
        self.model.storesWillChange(notification)
    }
    
    func storesDidChange(notification: NSNotification) {
        self.model.storesDidChange(notification)
    }
    
    func persistentStoreDidImportUbiquitousContentChanges(notification: NSNotification) {
        self.model.persistentStoreDidImportUbiquitousContentChanges(notification)
    }

    /*func handleUbiquitousKeyValueStoreChanges(notification: NSNotification) {

        let userInfo = notification.userInfo
        let reason: NSInteger = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as NSInteger

        switch reason {
            case NSUbiquitousKeyValueStoreServerChange:
                // Updated values
                break
            case NSUbiquitousKeyValueStoreInitialSyncChange:
                // First launch
                break
            case NSUbiquitousKeyValueStoreQuotaViolationChange:
                // No free space
                break
            case NSUbiquitousKeyValueStoreAccountChange:
                // iCloud accound changed
                break
        }
    }*/
    
    func refreshUI() {
        NSNotificationCenter.defaultCenter().postNotificationName(refreshUIKey, object: nil)
    }
    
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        if url.scheme == "countr" {
            if url.host == "add" {
                let urlParser = LKURLParser(URL: url)
                
                let title: String = urlParser.valueForVariable("title").stringByRemovingPercentEncoding!
                let date: NSDate = NSDate(timeIntervalSince1970: ((urlParser.valueForVariable("date") as NSString).doubleValue))
                let mode: LKCountdownMode = LKCountdownMode(string: urlParser.valueForVariable("mode"))
                
                
                let countdownItem = LKCountdownItem(title: title, date: date, mode: mode)
                
                LKCountdownManager.sharedInstance.saveNewCountdownItem(countdownItem, completionHandler: nil)
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        setAppBadge()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        setAppBadge()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.model.saveContext()
        
        setAppBadge()
    }
    


}

