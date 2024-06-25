/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIView+UTTFinder.h"
#import "UIView+UTTReady.h"
#import "UTestTools.h"
#import "UTTConvertType.h"
#import "UTTUtils.h"

@implementation UIView (UTTFinder)
- (NSString *)uttComponent {
    if (self.class == [UIView class]) {
        return UTTComponentView;
    } else if (self.class == [UIToolbar class]) {
        return UTTComponentToolBar;
    } else if (self.class == NSClassFromString(@"UINavigationItemButtonView")) {
        return UTTComponentButton;
    } else if (self.class == NSClassFromString(@"UINavigationButton")) {
        return UTTComponentButton;
    } else if (self.class == NSClassFromString(@"UIThreePartButton")) {
        return UTTComponentButton;
    } else if (self.class == NSClassFromString(@"UIRoundedRectButton")) {
        return UTTComponentButton;
    } else if (self.class == NSClassFromString(@"UIToolbarTextButton")) {
        return UTTComponentButton;
    } else if (self.class == NSClassFromString(@"UIAlertButton")) {
        return UTTComponentButton;
    } else if (self.class == NSClassFromString(@"_UISwitchInternalView")) {
        return UTTComponentToggle;
    } else if (self.class == NSClassFromString(@"_UIWebViewScrollView")) {
        return UTTComponentScroller;
    }
    
    return NSStringFromClass(self.class);
}



- (void)constructComponentTree:(NSMutableArray *)tree {
    
    // Obviar vistas ocultas y sus subvistas
    
    if (self.hidden || self.alpha == 0) {
        return;
    }
    [tree addObject:[NSValue valueWithNonretainedObject:self]];
    for (UIView *subview in self.subviews) {
        [subview constructComponentTree:tree];
    }
}

+ (NSArray *)orderedViews {
    NSMutableArray *tree = [NSMutableArray array];
    UIView *root = [UTTUtils rootWindow];
    [root constructComponentTree:tree];
    
    for (UIView *view in [UIApplication sharedApplication].windows) {
        if (![[NSValue valueWithNonretainedObject:root] isEqualToValue:[NSValue valueWithNonretainedObject:view]]) {
            [view constructComponentTree:tree];
        }
    }
    
    NSMutableArray *orderedViews = [NSMutableArray array];
    NSArray *aliased = [self aliased];
    
    if (aliased) {
        for (NSString *classString in aliased) {
            Class class = NSClassFromString(classString);
            [orderedViews addObjectsFromArray:[class orderedViews]];
        }
    }
    
    if ([tree count] > 0) {
        [tree sortUsingComparator:^NSComparisonResult (NSValue *obj1, NSValue *obj2) {
            UIView *view1 = (UIView *)[obj1 nonretainedObjectValue];
            UIView *view2 = (UIView *)[obj2 nonretainedObjectValue];
            CGPoint point1 = [view1 convertPoint:view1.frame.origin toView:[UTTUtils rootWindow]];
            CGPoint point2 = [view2 convertPoint:view2.frame.origin toView:[UTTUtils rootWindow]];
            
            if (point1.y > point2.y)
            return NSOrderedDescending;
            else if (point1.y < point2.y)
            return NSOrderedAscending;
            else if (point1.x > point2.x)
            return NSOrderedDescending;
            else if (point1.x < point2.x)
            return NSOrderedAscending;
            else
            return NSOrderedSame;
        }];
    }
    
    for (NSValue *value in tree) {
        UIView *view = [value nonretainedObjectValue];
        BOOL shouldAddToPossibleComponents = [view isKindOfClass:self];
        
        if (shouldAddToPossibleComponents) {
            [orderedViews addObject:value];
        }
    }
    
    [tree removeAllObjects];
    return orderedViews;
}

+ (NSArray *)aliased {
    return nil;
}

+ (NSArray *)orderedViewsWithUTesterId:(NSString *)uTesterId {

    
    NSMutableArray *orderedViewsWithUTesterId = [[NSMutableArray alloc] init];
    NSArray *orderedViews = [self orderedViews];
    
    for (NSValue *value in orderedViews) {
        UIView *view = [value nonretainedObjectValue];
        BOOL uTesterIdMatches = [view.baseUTesterID isEqualToString:uTesterId] || [view.rawUTesterIDCandidates containsObject:uTesterId];
        
        if (uTesterIdMatches) {
            [orderedViewsWithUTesterId addObject:value];
        }
    }
    return orderedViewsWithUTesterId;
}


+ (UIView *)findViewFromEvent:(UTTCommandEvent *)event {
    NSString *classString = [UTTConvertType convertedComponentFromString:event.className isRecording:NO] ? [UTTConvertType convertedComponentFromString:event.className isRecording:NO] : event.className;
    Class findClass = NSClassFromString(classString);
    
    if (![findClass respondsToSelector:@selector(orderedViews)]) {
        return nil;
    }
    
    UIView *foundView = nil;
    NSRegularExpression *ordinalRegex = [NSRegularExpression regularExpressionWithPattern:@"^\\#(\\d+)$" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSRegularExpression *indexRegex = [NSRegularExpression regularExpressionWithPattern:@"^(.+?)\\((\\d+)\\)$" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    BOOL lookingForOrdinal = [ordinalRegex foundMatchInString:event.uTesterID];
    __block NSString *uTesterId = event.uTesterID;
    __block NSInteger matchIndex = lookingForOrdinal ? [[event.uTesterID stringByReplacingOccurrencesOfString:@"#" withString:@""] integerValue]-1 : 0;
    
    if ([uTesterId isEqualToString:@"*"] || [uTesterId isEqualToString:@"?"])
    lookingForOrdinal = YES;
    
    [indexRegex enumerateMatchesInString:uTesterId options:NSMatchingReportProgress range:NSMakeRange(0, [uTesterId length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
        NSInteger uTesterIdRange = 1;
        NSInteger indexRange = 2;
        matchIndex = [[uTesterId substringWithRange:[result rangeAtIndex:indexRange]] integerValue]-1;
        uTesterId = [uTesterId substringWithRange:[result rangeAtIndex:uTesterIdRange]];
    }];
    
    NSArray *possibleComponents = lookingForOrdinal ? [findClass orderedViews] : [findClass orderedViewsWithUTesterId:uTesterId];
    
    if (possibleComponents.count > 0 && possibleComponents.count > matchIndex) {
        NSValue *value = [possibleComponents objectAtIndex:matchIndex];
        foundView = [value nonretainedObjectValue];
        
        // Ignorar UITextFieldLabel como labels
        
        if ([event.component.lowercaseString isEqualToString:UTTComponentLabel.lowercaseString] &&
            foundView.class == NSClassFromString(@"UITextFieldLabel")) {
            while (foundView) {
                if (foundView.class == [UILabel class]) {
                    break;
                }
                
                if (possibleComponents.count > matchIndex+1) {
                    value = [possibleComponents objectAtIndex:matchIndex++];
                    foundView = [value nonretainedObjectValue];
                } else {
                    foundView = nil;
                }
            }
        }
    }
    
    return foundView;
}


@end