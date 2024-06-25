//
//  NSString+UTestTools.h
//  UTestTools
//
//  Created by Kyle Balogh on 3/27/12.
//  Copyright 2012 Gorilla Logic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (UTestTools)
- (BOOL)isEqualToString:(NSString *)aString ignoreCase:(BOOL)ignore;
@end
