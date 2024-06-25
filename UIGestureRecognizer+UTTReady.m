/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIGestureRecognizer+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "UTTUtils.h"
#import "UIView+UTTReady.h"
#import "UIGestureRecognizerProxy.h"
#import "NSString+UTestTools.h"
#import "UTTConvertType.h"
#import "UIGestureRecognizerProxy.h"
#import "UIGestureRecognizerTargetProxy.h"
#import "UITableView+UTTReady.h"
#import "UTTUtils.h"
#import "UIPanGestureRecognizerProxy.h"
#import "UILongPressGestureRecognizerProxy.h"
#import "UISwitch+UTTReady.h"

@interface UTTDefaultGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>
@end
@implementation UTTDefaultGestureRecognizerDelegate
@end

@implementation UIGestureRecognizer (UTTReady)
NSMutableArray *panArgs;

+ (void)load {
    if (self == [UIGestureRecognizer class]) {
        Method originalMethod = class_getInstanceMethod(self, @selector(initWithTarget:action:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttinitWithTarget:action:));
        method_exchangeImplementations(originalMethod, replacedMethod);
        panArgs = [[NSMutableArray alloc] init];
    }
}

+ (NSString *) directionForInt:(NSInteger)direction {
    NSString *directionString;
    if (direction == UISwipeGestureRecognizerDirectionUp)
        directionString = UTTSwipeDirectionUp;
    else if (direction == UISwipeGestureRecognizerDirectionDown)
        directionString = UTTSwipeDirectionDown;
    else if (direction == UISwipeGestureRecognizerDirectionLeft)
        directionString = UTTSwipeDirectionLeft;
    else
        directionString = UTTSwipeDirectionRight;
    
    return directionString;
}


- (void) uttreplaceAction:(UIGestureRecognizer *)recognizer {
    
    if ([recognizer.view isKindOfClass:objc_getClass("_UISwitchInternalViewNeueStyle1")]) {
        UISwitch *parentSwitch = [UISwitch parentSwitchFromInternalView:recognizer.view];
        
        if (parentSwitch) {
            return [parentSwitch handleSwitchGesture:recognizer];
        }
    }
    
    
    
    NSString *objectString = [NSString stringWithFormat:@"%@",recognizer];
    NSArray *replaceStrings = [NSArray arrayWithObjects:@"\n",@"\"",@" ",@"(",@")", nil];
    NSArray *args = nil;
    NSString *command = nil;
    
    for (NSString *string in replaceStrings)
        objectString = [objectString stringByReplacingOccurrencesOfString:string withString:@""];
    
    
    NSArray *array = [objectString componentsSeparatedByString:@";"];
    
    for (__strong NSString *string in array) {
        if ([string rangeOfString:@"target="].location != NSNotFound) {
            string = [string stringByReplacingOccurrencesOfString:@"=<" withString:@","];
        }
    }
    
    if ([self isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipeRecognizer = (UISwipeGestureRecognizer *)recognizer;
        
        NSString *directionString = [[self class] directionForInt:swipeRecognizer.direction];
        args = [NSArray arrayWithObject:directionString];
        command = UTTCommandSwipe;
        [UTestTools recordFrom:recognizer.view
                       command:command args:args];
        return;
        
    } else if ([self isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinchRecognizer = (UIPinchGestureRecognizer *)recognizer;
        
        NSString *scaleString = [NSString stringWithFormat:@"%0.2f",pinchRecognizer.scale];
        NSString *velocityString = [NSString stringWithFormat:@"%0.2f",pinchRecognizer.velocity];
        args = [NSArray arrayWithObjects:scaleString, velocityString, nil];
        command = UTTCommandPinch;
        [UTestTools recordFrom:recognizer.view
                       command:command args:args];
        return;
        
    } else if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *longGesure = (UILongPressGestureRecognizer *) recognizer;
        CGPoint touchPoint;
        if ([self.view isKindOfClass:[UITableView class]])
        {
            UITableView *uttTableView = self.view;
            touchPoint = [longGesure locationInView:uttTableView];
            NSIndexPath *indexPath =  [uttTableView indexPathForRowAtPoint:touchPoint];
            NSString *selectedRowId = [NSString stringWithFormat:@"%d",[indexPath row]+1];
            args = [NSArray arrayWithObject:selectedRowId];
            command = UTTCommandLongSelectIndex;
        }
        else if ([self.view isKindOfClass:[UIPickerView class]]) {
            
        }
        else
            command = UTTCommandLongPress;
        
        [UTestTools recordFrom:recognizer.view
                       command:command args:args];
        return;
        
    } else if ([self isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([self shouldIgnoreGesture])
            return;
        
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)recognizer;
        CGPoint translatePoint = [panGesture locationInView:self.view.superview];
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [panArgs addObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", translatePoint.x],
                                          [NSString stringWithFormat:@"%1.0f",translatePoint.y], nil]];
        }  else if (recognizer.state == UIGestureRecognizerStateEnded) {
            [panArgs addObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", translatePoint.x],
                                          [NSString stringWithFormat:@"%1.0f",translatePoint.y], nil]];
            
            [ UTestTools recordEvent:[[UTTCommandEvent alloc]
                                      init:UTTCommandDrag className:[NSString stringWithUTF8String:class_getName([recognizer.view class])]
                                      uTesterID:[recognizer.view uTesterID]
                                      args:[NSArray arrayWithArray:panArgs]]];
            [panArgs removeAllObjects];
            return;
        }
    }

}

- (BOOL)shouldIgnoreGesture {
    
    BOOL isScrollViewPan = [self isKindOfClass:objc_getClass("UIScrollViewPanGestureRecognizer")];
    BOOL isSwitch = [self.view isKindOfClass:[UISwitch class]] || [self.view isKindOfClass:objc_getClass("_UISwitchInternalView")];
    
    if (isScrollViewPan || isSwitch)
        return YES;

    return NO;
}

- (id) uttinitWithTarget:(id)target action:(SEL)action {
    [self uttinitWithTarget:target action:action];
    
    if ([self isKindOfClass:[UISwipeGestureRecognizer class]] ||
        [self isKindOfClass:[UIPinchGestureRecognizer class]] ||
        [self isKindOfClass:[UILongPressGestureRecognizer class]] ||
        [self isKindOfClass: [UITapGestureRecognizer class]] ||
        [self isKindOfClass:[UIPanGestureRecognizer class]]){
        [self addTarget:self action:@selector(uttreplaceAction:)];
    }
    
    return self;
}
@end
