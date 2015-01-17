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
        UILabel.appearance().font = UIFont(name: "Avenir-Book", size: 17)
        //UILabel.appearance().textAlignment = NSTextAlignment.Center
        
        application.registerForRemoteNotifications()
        
        self.registerForiCloudNotifications()
        
        
        return true
    }
    
    func registerForiCloudNotifications() {
        println("registerForiCloudNotifications")
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "storesWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.model.persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: "storesDidChange:", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: self.model.persistentStoreCoordinator)
        notificationCenter.addObserver(self, selector: "persistentStoreDidImportUbiquitousContentChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: self.model.persistentStoreCoordinator)
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

