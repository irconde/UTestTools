/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UISwitch+UTTReady.h"
#import "UTestTools.h"
#import "UTTUtils.h"
#import "UTTCommandEvent.h"
#import "NSString+UTestTools.h"
#import "UIView+UTTReady.h"

@implementation _UISwitchInternalViewNeueStyle1

@end
@implementation _UISwitchInternalViewNeueStyle1 (UTTReady)
- (BOOL) isUTTEnabled {
	return NO;
}
@end

@implementation UISwitch (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentSwitch;
}

+ (UISwitch *)parentSwitchFromInternalView:(UIView *)view {
    UISwitch *superSwitch = (UISwitch *)view;
    
    while (![superSwitch isKindOfClass:[UISwitch class]]) {
        if (!superSwitch.superview) {
            return nil;
        }
        superSwitch = (UISwitch *)superSwitch.superview;
    }
    
    return superSwitch;
}


- (void)recordSwitchTap {
    NSString *command = UTTCommandOff;
    
    if (!self.on)
        command = UTTCommandOn;
    [UTestTools recordFrom:self command:command];
}

- (void)handleSwitchGesture:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UISwipeGestureRecognizer class]] || [recognizer isKindOfClass:[UIPanGestureRecognizer class]] ||
        recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    return [self recordSwitchTap];
}

- (void) handleSwitchTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    
    if (touch.phase == UITouchPhaseEnded) {
        [self recordSwitchTap];
    }
        
}

@end
