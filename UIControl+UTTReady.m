/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIControl+UTTReady.h"
#import <UIKit/UIControl.h>
#import <objc/runtime.h>
#import "UTestTools.h"


@implementation UIControl (UTTReady)

+ (void)load {
    if (self == [UIControl class]) {
		Method originalMethod = class_getInstanceMethod(self, @selector(initWithCoder:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttInitWithCoder:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}

- (void) subscribeToUTesterEvents {
	if (self.uTestEventsToHandle != 0) {
		[self addTarget:self action:@selector(handleUTesterEventFromSender:forEvent:) forControlEvents:self.uTestEventsToHandle];
	}
}

- (id)uttInitWithCoder:(NSCoder *)decoder {
	
    [self uttInitWithCoder:decoder];
	if (self) {
		[self subscribeToUTesterEvents];
	}
	return self;
}



- (UIControlEvents) uTestEventsToHandle {
	
	return 0;
}
- (void) handleUTesterEventFromSender:(id)sender forEvent:(UIEvent*)event {
	
}

@end
