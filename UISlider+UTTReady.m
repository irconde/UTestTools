/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UISlider+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import "UTTUtils.h"
#import "NSString+UTestTools.h"

@implementation UISlider (UTTReady)
- (NSString *)uttComponent {
    return UTTComponentSlider;
}

- (BOOL) isUTTEnabled {
	return YES;
}


- (UIControlEvents)uTestEventsToHandle {
		return UIControlEventValueChanged;
}


- (void) handleUTesterEventFromSender:(id)sender forEvent:(UIEvent*)event {

	if (event && [event isKindOfClass:[UIEvent class]]) {
		if (event.type == UIEventTypeTouches) {
			UITouch* touch = [[event allTouches] anyObject];
			
			if (touch == nil || touch.phase == UITouchPhaseEnded) {
				
               
                if ([self respondsToSelector:@selector(accessibilityIdentifier)] && [self accessibilityIdentifier] == nil) {
                    [self setAccessibilityIdentifier:[sender accessibilityIdentifier]];
                } else if ([self accessibilityLabel] == nil) {
					[self setAccessibilityLabel:[sender accessibilityLabel]];
				}

				if ([self isMemberOfClass:[UISlider class]] || [self isKindOfClass:[UISlider class]]) {
					[UTestTools recordFrom:self command:UTTCommandSelect args:[NSArray arrayWithObject:[[NSString alloc] initWithFormat:@"%.2f",self.value]]];
				} else {
					
					[UTestTools recordFrom:sender command:UTTCommandSwitch];
				}
		
			}
		}
		
		return;
	} 
	
}	


- (BOOL) shouldRecordUTester:(UITouch*)phase {
	return NO;
}


@end
