//
// Created by Lukas Kollmer on 26/07/14.
// Copyright (c) 2014 Lukas Kollmer. All rights reserved.
//

#import "UIApplication+AppInfo.h"



@implementation UIApplication (AppInfo)

#pragma mark - General app info
- (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
}

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBuild
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
- (NSString *)appBundleID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)documentsFolderSizeAsString
{
    NSString *folderPath = [self documentsDirectoryPath];
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    
    unsigned long long int folderSize = 0;
    
    for (NSString *fileName in filesArray) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        folderSize += [fileDictionary fileSize];
    }
    
    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

- (int)documentsFolderSizeInBytes
{
    
    NSString *folderPath = [self documentsDirectoryPath];
    
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    unsigned long long int folderSize = 0;
    
    for (NSString *fileName in filesArray) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        folderSize += [fileDictionary fileSize];
    }
    
    
    return (int)folderSize;
}

#pragma mark - Privacy data access

- (BOOL)applicationHasAccessToLocationData
{
    
    BOOL hasAccess = NO;
    switch ([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusNotDetermined:
            hasAccess = NO;
            break;
        case kCLAuthorizationStatusRestricted:
            hasAccess = NO;
            break;
        case kCLAuthorizationStatusDenied:
            hasAccess = NO;
            break;
        case kCLAuthorizationStatusAuthorized:
            hasAccess = YES;
            break;
    }
    
    return hasAccess;
}

- (BOOL)applicationhasAccessToAddressBook
{
    BOOL hasAccess = NO;
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
        case kABAuthorizationStatusNotDetermined:
            hasAccess = NO;
            break;
        case kABAuthorizationStatusRestricted:
            hasAccess = NO;
            break;
        case kABAuthorizationStatusDenied:
            hasAccess = NO;
            break;
        case kABAuthorizationStatusAuthorized:
            hasAccess = YES;
            break;
    }
    
    
    return hasAccess;
}

- (BOOL)applicationHasAccessToCalendar
{
    
    BOOL hasAccess = NO;
    
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent])
    {
        case EKAuthorizationStatusNotDetermined:
            hasAccess = NO;
            break;
        case EKAuthorizationStatusRestricted:
            hasAccess = NO;
            break;
        case EKAuthorizationStatusDenied:
            hasAccess = NO;
            break;
        case EKAuthorizationStatusAuthorized:
            hasAccess = YES;
            break;
    }
    
    return hasAccess;
}


- (BOOL)applicationHasAccessToReminders
{
    
    BOOL hasAccess = NO;
    switch ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder])
    {
        case EKAuthorizationStatusNotDetermined:
            hasAccess = NO;
            break;
        case EKAuthorizationStatusRestricted:
            hasAccess = NO;
            break;
        case EKAuthorizationStatusDenied:
            hasAccess = NO;
            break;
        case EKAuthorizationStatusAuthorized:
            hasAccess = YES;
            break;
    }
    
    return hasAccess;
}


- (BOOL)applicationHasAccessToPhotosLibrary
{
    BOOL hasAccess = NO;
    
    switch ([ALAssetsLibrary authorizationStatus])
    {
        case ALAuthorizationStatusNotDetermined:
            hasAccess = NO;
            break;
        case ALAuthorizationStatusRestricted:
            hasAccess = NO;
            break;
        case ALAuthorizationStatusDenied:
            hasAccess = NO;
            break;
        case ALAuthorizationStatusAuthorized:
            hasAccess = YES;
            break;
            
            
    }
    
    return hasAccess;
}
/*
- (BOOL)applicationHasAccessToMicrophone
{
    BOOL hasAccess = NO;
    
    switch ([[AVAudioSession sharedInstance] recordPermission])
    {
        case AVAudioSessionRecordPermissionUndetermined:
            // Recording permission has not been granted or denied.
            // This typically means that permision has yet to be requested, or is in the process of being requested.
            hasAccess = NO;
            break;
        case AVAudioSessionRecordPermissionDenied:
            // Recording permission has been denied.
            hasAccess = NO;
            break;
        case AVAudioSessionRecordPermissionGranted:
            // Recording permission has been denied.
            hasAccess = YES;
            break;
            
    }
    
    return hasAccess;
}
*/


#pragma mark - Private methods
- (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return documentsPath;
}
@end