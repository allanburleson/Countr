//
// Created by Lukas Kollmer on 26/07/14.
// Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AddressBook/ABAddressBook.h"
#import "EventKit/EventKit.h"
#import "AVFoundation/AVFoundation.h"
#import "AssetsLibrary/AssetsLibrary.h"

@interface UIApplication (AppInfo)

- (NSString *)appName;

- (NSString *)appVersion;

- (NSString *)appBuild;

- (NSString *)appBundleID;

- (NSString *)documentsFolderSizeAsString;

- (int)documentsFolderSizeInBytes;

- (BOOL)applicationHasAccessToLocationData;

- (BOOL)applicationhasAccessToAddressBook;

- (BOOL)applicationHasAccessToCalendar;

- (BOOL)applicationHasAccessToReminders;

- (BOOL)applicationHasAccessToPhotosLibrary;

/*
- (BOOL)applicationHasAccessToMicrophone;
*/
@end
