//
//  objc_Extensions.m
//  Countr
//
//  Created by Lukas Kollmer on 1/27/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

#import "objc_Extensions.h"
#import "Countr-Swift.h"


/*
 Returns the UIInterfaceOrientation masks foe each ViewController
 */
NSUInteger interfaceOrientationsForClass(id _class) {
    
    NSLog(@"_class: %@", _class);
    
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
        return interfaceOrientationsForClass([(UINavigationController *)_class topViewController]);
    }
    
    NSLog(@"else");
    return UIInterfaceOrientationMaskPortrait;
}

/*
Disable rotation based on the current ViewController class
 */
@implementation UIViewController (NoRotation)

- (NSUInteger)supportedInterfaceOrientations {
    return interfaceOrientationsForClass(self);
}

@end

/**
 Ignore the warnings for overriding the following methods
 
 The clang warning code is "[-Wobjc-protocol-method-implementation]"
 */


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"


@implementation UIFont (MySystemFont)
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Avenir-Book" size:fontSize];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Avenir-Heavy" size:fontSize];
}

+ (UIFont *)italicSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Avenir-BookOblique" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight {
    return [UIFont fontWithName:@"Avenir-Book" size:fontSize];
}

@end
#pragma clang diagnostic pop