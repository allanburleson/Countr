//
//  objc_Extensions.m
//  Countr
//
//  Created by Lukas Kollmer on 1/27/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

#import "objc_Extensions.h"


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