//
//  objc_Extensions.m
//  Countr
//
//  Created by Lukas Kollmer on 1/27/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

#import "objc_Extensions.h"
#import "Countr-Swift.h"
#import <objc/runtime.h>


/*
 Returns the UIInterfaceOrientation masks foe each ViewController
 */
NSUInteger LKInterfaceOrientationsForClass(id _class, UIInterfaceOrientation interfaceOrientation, UIUserInterfaceIdiom interfaceIdiom) {
    
    // Allow all orientations on iPad
    if (interfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    
    // LKMainViewController
    if ([_class isKindOfClass: [LKMainViewController class]]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    // LKMainViewController
    if ([_class isKindOfClass: [LKInfoViewController class]]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    // LKMainViewController
    if ([_class isKindOfClass: [LKEditItemPropertiesViewController class]]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    // LKMainViewController
    if ([_class isKindOfClass: [LKItemDetailViewController class]]) {
        return UIInterfaceOrientationMaskAll; // TODO: Adapt for .All
    }
    
    // LKMainViewController
    if ([_class isKindOfClass: [LKPurchasePremiumViewController class]]) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    /*
     Sometimes (eg: the infoViewController), the ViewController is embedded in an UINavigationController. This if clause checks if the viewController is an UINavigationController. If this is true, it will call this very function with the navigationControllers topViewController as parameter.
     
     @discussion: This actually works!!!
     */
    if ([_class isKindOfClass:[UINavigationController class]]) {
        return LKInterfaceOrientationsForClass([(UINavigationController *)_class topViewController], interfaceOrientation, interfaceIdiom);
    }
    
    
    return UIInterfaceOrientationMaskPortrait;
}

/*
Disable rotation based on the current ViewController class
 */
@implementation UIViewController (NoRotation)

- (NSUInteger)supportedInterfaceOrientations {
    return LKInterfaceOrientationsForClass(self, [UIApplication sharedApplication].statusBarOrientation, self.traitCollection.userInterfaceIdiom);
}

@end



@implementation UITableViewHeaderFooterView (CustomFont)

/*
 Overriding this internal method allows us to use Avenir as font in the TableView header and footer
 
 NOTE: This cannot be used with a font set to UILabel via UIAppearance (eg UILabel.appearance().font = font)
 ("https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/UIKit.framework/UITableViewHeaderFooterView.h#L66")
 */
+ (UIFont *)_defaultFontForTableViewStyle:(int)arg1 isSectionHeader:(BOOL)arg2 {
    NSLog(@"UITableViewHeaderFooterView: _defaultFontForTableViewStyle: %d, isSectionHeader: %i", arg1, arg2);
    if (arg2) { // is Header
        return [UIFont boldSystemFontOfSize:15];
    } else {    // is Footer
        return [UIFont systemFontOfSize:14];
    }
}

+ (UIColor *)_defaultTextColorForTableViewStyle:(int)arg1 isSectionHeader:(BOOL)arg2 {
    NSLog(@"UITableViewHeaderFooterView: _defaultTextColorForTableViewStyle: %d, isSectionHeader: %i", arg1, arg2);
    
    return [UIColor lightGrayColor];
}

@end
