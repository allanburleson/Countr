//
// Created by Lukas Kollmer on 21/12/14.
// Copyright (c) 2014 LukasKollmer. All rights reserved.
//

#import "LKURLParser.h"


@interface LKURLParser ()
@property(nonatomic, strong) NSMutableArray *variables;

@property(nonatomic, strong) NSString *urlString;
@end

@implementation LKURLParser {

}
- (instancetype)initWithURLString:(NSString *)url {

    self.urlString = url;
    [self commonInit];
    
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {

    self.urlString = url.absoluteString;
    [self commonInit];
    
    return self;
}


- (void)commonInit {
    NSScanner *scanner = [NSScanner scannerWithString:self.urlString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
    NSString *tempString;
    NSMutableArray *vars = [NSMutableArray new];
    [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
    while ([scanner scanUpToString:@"&" intoString:&tempString]) {
        [vars addObject:[tempString copy]];
    }
    self.variables = vars;
}

- (NSString *)valueForVariable:(NSString *)varName
{
    for (NSString *var in self.variables) {
        if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }
    return nil;
}

- (NSMutableArray *)logVariables {
    return self.variables;
}

@end