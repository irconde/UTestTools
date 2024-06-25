//
//  NSString+UTestTools.m
//  UTestTools
//
//  Created by Kyle Balogh on 3/27/12.
//  Copyright 2012 Gorilla Logic, Inc. All rights reserved.
//

#import "NSString+UTestTools.h"


@implementation NSString (UTestTools)
- (BOOL)isEqualToString:(NSString *)aString ignoreCase:(BOOL)ignore {
    if (ignore)
        return [[self lowercaseString] isEqualToString:[aString lowercaseString]];
    
    return [self isEqualToString:aString];
}

@end
