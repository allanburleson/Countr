//
//  objc_Extensions.h
//  Countr
//
//  Created by Lukas Kollmer on 1/27/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIFont (MySystemFont)

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize;

+ (UIFont *)italicSystemFontOfSize:(CGFloat)fontSize;

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight;


@end