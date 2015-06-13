//
//  UIFont+CustomFont.m
//  Countr
//
//  Created by Lukas Kollmer on 6/13/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

/*
 This is a class that is only used for storing the implementations of the methods that will be swizzled
 */
@interface LKSwizzledImplementationStorage : NSObject
@property (nonatomic) Method original;
@property (nonatomic) Method swizzled;
@end

@implementation LKSwizzledImplementationStorage
@end


/**
 Ignore the warnings for overriding the following methods
 
 The clang warning code is "[-Wobjc-protocol-method-implementation]"
 */


#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation" // Ignore overridden system methods
//#pragma clang diagnostic ignored "-Wincomplete-implementation" // Ignore missing overridden system methods

@implementation UIFont (CustomSystemFont)

+ (void)load {
    [super load];
    
    //////////////////////////////
    // swizzle the font methods //
    //////////////////////////////
    
    
    LKSwizzledImplementationStorage *systemFontOfSizeImplementations = [LKSwizzledImplementationStorage new];
    LKSwizzledImplementationStorage *boldSystemFontOfSizeImplementations = [LKSwizzledImplementationStorage new];
    LKSwizzledImplementationStorage *italicSystemFontOfSizeImplementations = [LKSwizzledImplementationStorage new];
    LKSwizzledImplementationStorage *systemFontOfSizeWeightImplementations = [LKSwizzledImplementationStorage new];
    
    
    // -systemFontofSize
    
    systemFontOfSizeImplementations.original = class_getClassMethod(self, @selector(systemFontOfSize:));
    systemFontOfSizeImplementations.swizzled = class_getClassMethod(self, @selector(swizzledSystemFontOfSize:));
    
    
    // -boldSystemFontofSize
    
    boldSystemFontOfSizeImplementations.original = class_getClassMethod(self, @selector(boldSystemFontOfSize:));
    boldSystemFontOfSizeImplementations.swizzled = class_getClassMethod(self, @selector(swizzledBoldSystemFontOfSize:));
    
    
    // -italicSystemFontofSize
    
    italicSystemFontOfSizeImplementations.original = class_getClassMethod(self, @selector(italicSystemFontOfSize:));
    italicSystemFontOfSizeImplementations.swizzled = class_getClassMethod(self, @selector(swizzledItalicSystemFontOfSize:));
    
    
    // -systemFontofSizeWeight
    
    systemFontOfSizeWeightImplementations.original = class_getClassMethod(self, @selector(systemFontOfSize:weight:));
    systemFontOfSizeWeightImplementations.swizzled = class_getClassMethod(self, @selector(swizzledSystemFontOfSize:weight:));
    
    NSArray *implementations = @[systemFontOfSizeImplementations,
                                 boldSystemFontOfSizeImplementations,
                                 italicSystemFontOfSizeImplementations,
                                 systemFontOfSizeWeightImplementations
                                 ];
    
    for (LKSwizzledImplementationStorage *swizzledImplementation in implementations) {
        method_exchangeImplementations(swizzledImplementation.original, swizzledImplementation.swizzled);
    }
    
}


// Swizzled methods

+ (UIFont *)swizzledSystemFontOfSize:(CGFloat)fontSize {
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    if (osVersion.majorVersion < 9) {
        return [UIFont fontWithName:@"Avenir-Book" size:fontSize];
    } else {
        return [self swizzledSystemFontOfSize:fontSize];
    }
}

+ (UIFont *)swizzledBoldSystemFontOfSize:(CGFloat)fontSize {
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    if (osVersion.majorVersion < 9) {
        return [UIFont fontWithName:@"Avenir-Heavy" size:fontSize];
    } else {
        return [self swizzledSystemFontOfSize:fontSize];
    }
}

+ (UIFont *)swizzledItalicSystemFontOfSize:(CGFloat)fontSize {
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    if (osVersion.majorVersion < 9) {
        return [UIFont fontWithName:@"Avenir-BookOblique" size:fontSize];
    } else {
        return [self swizzledSystemFontOfSize:fontSize];
    }
}

+ (UIFont *)swizzledSystemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight {
    
    NSOperatingSystemVersion osVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    
    if (osVersion.majorVersion < 9) {
        return [UIFont fontWithName:@"Avenir-Book" size:fontSize];
    } else {
        return [self swizzledSystemFontOfSize:fontSize];
    }
}


@end
#pragma clang diagnostic pop
