//
//  NSRegularExpression+UTestTools.m
//  UTestTools
//
//  Created by Kyle Balogh on 9/9/13.
//  Copyright (c) 2013 Gorilla Logic, Inc. All rights reserved.
//

#import "NSRegularExpression+UTestTools.h"

@implementation NSRegularExpression (UTestTools)
- (BOOL)foundMatchInString:(NSString *)matchString {
    NSRange matchRange = NSMakeRange(0, [matchString length]);
    NSTextCheckingResult *result = [self firstMatchInString:matchString options:NSRegularExpressionDotMatchesLineSeparators range:matchRange];
    
    BOOL found = result && NSEqualRanges(result.range, matchRange);
    
    return found;
}
@end
