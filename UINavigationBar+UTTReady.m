/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UINavigationBar+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import <objc/runtime.h>
#import "UTTUtils.h"


@implementation UINavigationBar (UTTReady)

+ (void)load {
    if (self == [UINavigationBar class]) {
        Method originalMethod = class_getInstanceMethod(self, @selector(popNavigationItemAnimated:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttpopNavigationItemAnimated:));
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

- (NSString*) baseUTesterID {
	// Default identifier is the component tag
	NSString* title = [[self topItem] title];
	if (title && title.length>0) {
		return [title copy];
	}
	return [super baseUTesterID];
}

- (BOOL) shouldRecordUTester:(UITouch*)touch {	
	return (touch.phase == UITouchPhaseBegan);
}

- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch* touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self];
    
    NSLog(@"SubVistas: %@",self.subviews);
    
    for (int i = 0; i < [self.subviews count]; i++) {
        UIView *view = [self.subviews objectAtIndex:i];
        if (CGRectContainsPoint(view.frame, loc) && 
            [view isKindOfClass:objc_getClass("UINavigationItemButtonView")])
            
            [UTestTools recordFrom:view command:UTTCommandTap args:
             [NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", loc.x],
                                       [NSString stringWithFormat:@"%1.0f",loc.y],
                                        nil]];
    }
	
}


- (UINavigationItem *) uttpopNavigationItemAnimated:(BOOL)animated
{
    if ([UTestTools sharedUTester].commandSpeed != nil && [[UTestTools sharedUTester].commandSpeed doubleValue] < 333333)
        animated = NO;
    
    [self uttpopNavigationItemAnimated:animated];
    
    return nil;
}

@end
