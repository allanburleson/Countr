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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let model = LKModel.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let font = UIFont(name: "Avenir-Book", size: 17)!
        UILabel.appearance().font = font
        UIButton.appearance().titleLabel?.font = UIFont(name: "Avenir-Book", size: 15)
        //UITextField.appearance().backgroundColor = UIColor.foregroundColor()
        UITableViewCell.appearance().backgroundColor = UIColor.foregroundColor()
        UICollectionView.appearance().backgroundColor = UIColor.backgroundColor()
        UINavigationBar.appearance().barStyle = .Black
        UIToolbar.appearance().barStyle = .Black
        UIToolbar.appearance().tintColor = UIColor.whiteColor()
        UITextField.appearance().tintColor = UIColor.whiteColor()
        let titleTextAttributes: [NSObject : AnyObject] = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIBarButtonItem.appearance().setTitleTextAttributes(titleTextAttributes, forState: UIControlState.Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(titleTextAttributes, forState: UIControlState.Highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes(titleTextAttributes, forState: UIControlState.Disabled)
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
        let segmentedControlTitleTextAttributes: [NSObject : AnyObject] = [NSFontAttributeName : UIFont(name: "Avenir-Book", size: 13)!]
        UISegmentedControl.appearance().setTitleTextAttributes(segmentedControlTitleTextAttributes, forState: UIControlState.Normal)
        
        application.registerForRemoteNotifications()
        
        

        let localNotificationSettings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        application.registerUserNotificationSettings(localNotificationSettings)
        
        
        let countdownManager = LKCountdownManager.sharedInstance
        countdownManager.updateApplicationBadgeToNumberOfItemsDueToday()
        
        self.registerForiCloudNotifications()
        
        
        
        // Setup Google Analytics
        GAI.sharedInstance().trackUncaughtExceptions = true
        //GAI.sharedInstance().logger.logLevel = GAILogLevel.Verbose
        GAI.sharedInstance().trackerWithTrackingId("UA-49744076-4")
        
        
        // Setup background fetch
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("application(application:, performFetchWithCompletionHandler")
        
        /////////////////////////////////
        //      Duration Counting      //
        /////////////////////////////////
        
        // TODO: Remove this before submission
        let startDate = NSDate()
        
        
        /////////////////////////////////
        // Save Data for the Extension //
        /////////////////////////////////
        
        let countdownManager = LKCountdownManager.sharedInstance
        countdownManager.saveDataForExtension()
        
        /////////////////////////////////
        //  Update Application Badge   //
        /////////////////////////////////
        
        countdownManager.updateApplicationBadgeToNumberOfItemsDueToday()
        
        println("abckgroundFetchEnded. Duration: \(startDate.timeIntervalSinceNow.positive) seconds")
        
        
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

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.model.saveContext()
    }
    


}

