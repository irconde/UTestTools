/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTOrdinalView.h"
#import "UTTUtils.h"
#import "NSString+UTestTools.h"
#import "UIView+UTTReady.h"

@implementation UTTOrdinalView

+ (NSMutableArray *) foundComponents {
    return [UTestTools sharedUTester].foundComponents;
}


+ (NSInteger) componentOrdinalForView:(UIView *)view withUTesterID:(NSString *)uTesterID {
    if ([view hasUTesterIdAssigned]) {
        return view.uttOrdinal;
    } else if (!view.isUTTEnabled) {
        return 1;
    }
    
    NSInteger ordinal = 1;
    [UTTOrdinalView buildFoundComponentsStartingFromView:nil havingClass:[NSString stringWithFormat:@"%@",[view class]] isOrdinalMid:YES];
    [UTTOrdinalView sortFoundComponents:[UTestTools sharedUTester].uTesterComponents];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [[UTestTools sharedUTester].uTesterComponents count]; i++) {
        UIView *found = (UIView *)[[UTestTools sharedUTester].uTesterComponents objectAtIndex:i];
        NSString *foundID = found.baseUTesterID;
        if (!uTesterID || [uTesterID isEqualToString:foundID]) {
            [temp addObject:found];
        }
    }
    
    if ([temp count] > 1) {
        for (int i = 0; i < [temp count]; i++) {
            UIView *found = (UIView *)[temp objectAtIndex:i];
            if (found == view) {
                ordinal = i + 1;
                break;
            }
        }
    }
    
    NSString *ordinalString = [NSString stringWithFormat:@"%i",ordinal];
    NSString *mid = view.baseUTesterID;
    if ([mid isEqualToString:@"#utt"])
        mid = [NSString stringWithFormat:@"#%@",ordinalString];
    
    NSArray *objects = [NSArray arrayWithObjects:mid, ordinalString, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"uTesterID", @"ordinal", nil];
    NSDictionary *item = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [[UTestTools sharedUTester].componentUTesterIds setObject:item forKey:[view keyForUTesterId]];
    
    [[UTestTools sharedUTester].uTesterComponents removeAllObjects];
    [UTestTools sharedUTester].uTesterComponents = nil;
    [UTestTools sharedUTester].uTesterComponents;
    
    return ordinal;
}

+ (UIView*) buildFoundComponentsStartingFromView:(UIView*)current havingClass:(NSString *)classString isOrdinalMid:(BOOL)isOrdinal {
    return [self buildFoundComponentsStartingFromView:current havingClass:classString isOrdinalMid:isOrdinal skipWebView:NO];
}

+ (UIView*) buildFoundComponentsStartingFromView:(UIView*)current havingClass:(NSString *)classString isOrdinalMid:(BOOL)isOrdinal skipWebView:(BOOL)skipWebView {
    Class class = objc_getClass([classString UTF8String]);
    
    if (!current) {
		current =  [UTTUtils rootWindow];
	}
    
    
    if (classString == nil) { 
        return current;
    }
    
    BOOL isButton = [UTTUtils shouldRecord:classString view:current];
    
    if ([classString.lowercaseString isEqualToString:@"uttcomponenttree"]) {
        
        if (isOrdinal) {
            if (![UTestTools sharedUTester].uTesterComponents) {
                [UTestTools sharedUTester].uTesterComponents = [[NSMutableArray alloc] init];
            }
            
            [[UTestTools sharedUTester].uTesterComponents addObject:current];
        } else {
            if (![UTestTools sharedUTester].foundComponents) {
                [UTestTools sharedUTester].foundComponents = [[NSMutableArray alloc] init];
            }

            [[UTestTools sharedUTester].foundComponents addObject:current];
        }
    } else if ( (classString != nil && ([current isKindOfClass:class] || isButton))) {

        if ([current isKindOfClass:class] ||
            ![classString isEqualToString:@"UILabel"] || 
            [classString.lowercaseString isEqualToString:@"itemselector"] ||
            [classString.lowercaseString isEqualToString:@"indexedselector"]) {
            
            if (isOrdinal) {
                if (![UTestTools sharedUTester].uTesterComponents) {
                    [UTestTools sharedUTester].uTesterComponents = [[NSMutableArray alloc] init];
                }
                
                [[UTestTools sharedUTester].uTesterComponents addObject:current];
                
            } else {
                if (![UTestTools sharedUTester].foundComponents) {
                    [UTestTools sharedUTester].foundComponents = [[NSMutableArray alloc] init];
                }
                
                [[UTestTools sharedUTester].foundComponents addObject:current];
            }
        }
    }
	
	if (!current.subviews) {
		return nil;
	}
    
    NSArray *subviews = [[NSArray alloc] initWithArray:current.subviews];
	
    for (UIView* view in [[subviews reverseObjectEnumerator] allObjects]) {
		UIView* result = [self buildFoundComponentsStartingFromView:view havingClass:classString isOrdinalMid:isOrdinal skipWebView:skipWebView];
		if (result) {
			return result;
		}
	}
    
    return nil;
}

+ (void) sortFoundComponents {
    [[self class] sortFoundComponents:[UTestTools sharedUTester].foundComponents];
}

+ (void) sortFoundComponents:(NSMutableArray *)components {
    if ([components count] > 0) {
        [components sortUsingComparator:  
         ^NSComparisonResult (id obj1, id obj2) {  
             UIView *view1 = (UIView *)obj1;
             UIView *view2 = (UIView *)obj2;
             CGPoint point1 = [view1 convertPoint:view1.frame.origin toView:nil];
             CGPoint point2 = [view2 convertPoint:view2.frame.origin toView:nil];  
             
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
         }  
         ];
    }
}


@end
