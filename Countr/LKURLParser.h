//
// Created by Lukas Kollmer on 21/12/14.
// Copyright (c) 2014 LukasKollmer. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LKURLParser : NSObject

- (instancetype)initWithURLString:(NSString *)url;
- (instancetype)initWithURL:(NSURL *)url;

- (NSString *)valueForVariable:(NSString *)varName;

- (NSMutableArray *)logVariables;
@end