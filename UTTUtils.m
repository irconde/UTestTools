/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <objc/runtime.h>

#import "UTTUtils.h"
#import "UIView+UTTReady.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIMotionEventProxy.h"
#import "UTTWindow.h"
#import "UTestTools.h"
#import <dlfcn.h>
#import "UTTOrdinalView.h"
#import "UTTConvertType.h"
#import "NSString+UTestTools.h"
#import "UIDevice+Hardware.h"

@interface UTTUtils ()
@end

@implementation UTTUtils
+ (void)load {

}

+ (UIWindow *)rootWindow {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    return keyWindow != nil ? keyWindow : [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}



+ (UIView *)findFirstUTesterView:(UIView *)current {
    if (current == nil) {
        return nil;
    }
    
    if ([current isUTTEnabled]) {
        return current;
    }
    
    return [UTTUtils findFirstUTesterView:[current superview]];
}


+ (void)rotate:(UIInterfaceOrientation)orientation {
    [[UIDevice currentDevice] setOrientation:orientation];
}

+ (BOOL)isKeyboard:(UIView *)view {
    
    Class cls = view.window ? [view.window class] : [view class];
    return [[NSString stringWithUTF8String:class_getName(cls)] isEqualToString:@"UITextEffectsWindow"];
}



+ (NSString *)className:(NSObject *)ob {
    return [NSString stringWithUTF8String:class_getName([ob class])];
}


+ (NSString *)timeStamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss:SSS-dd/MM/YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}


+ (BOOL)isOs5Up {
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    if ([[osVersion substringToIndex:1] intValue] >= 5) {
        return YES;
    }
    
    return NO;
}



+ (BOOL)shouldRecord:(NSString *)classString view:(UIView *)current {
    
    NSString *currentString = NSStringFromClass([current class]);
    
    BOOL isButton = (([current isKindOfClass:objc_getClass("UIButton")] ||
                      [current isKindOfClass:objc_getClass("UINavigationButton")] ||
                      [current isKindOfClass:objc_getClass("UINavigationItemButtonView")] ||
                      [current isKindOfClass:objc_getClass("UIThreePartButton")] ||
                      [current isKindOfClass:objc_getClass("UIRoundedRectButton")] ||
                      [current isKindOfClass:objc_getClass("UIToolbarTextButton")]) &&
                     ([currentString isEqualToString:@"UIButton"] ||
                      [currentString isEqualToString:@"UINavigationButton"] ||
                      [currentString isEqualToString:@"UINavigationItemButtonView"] ||
                      [currentString isEqualToString:@"UIThreePartButton"] ||
                      [currentString isEqualToString:@"UIRoundedRectButton"] ||
                      [currentString isEqualToString:@"UIToolbarTextButton"]));
    
    isButton = isButton && [classString isEqualToString:@"UIButton"];
    
    BOOL isIndexedSelector = (([classString isEqualToString:@"indexedselector" ignoreCase:YES]) &&
                              ([current isKindOfClass:objc_getClass("UIToolBar")] ||
                               [current isKindOfClass:objc_getClass("UITabBar")] ||
                               [current isKindOfClass:objc_getClass("UITableView")]));
    
    BOOL isItemSelector = (([classString isEqualToString:@"itemselector" ignoreCase:YES]) &&
                           ([current isKindOfClass:objc_getClass("UITabBar")] ||
                            [current isKindOfClass:objc_getClass("UITableView")]));
    
    return isButton || isIndexedSelector || isItemSelector;
}



@end
