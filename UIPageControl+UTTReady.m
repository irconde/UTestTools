/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIPageControl+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import "UTTUtils.h"
#import "NSString+UTestTools.h"

@implementation UIPageControl (UTTReady)


-(BOOL) isUTTEnabled {
    return YES;
}

- (UIControlEvents)uTestEventsToHandle {
    return UIControlEventValueChanged;
}

- (BOOL) shouldRecordUTester:(UITouch*)phase {
	return NO;
}

- (void) handleUTesterEventFromSender:(id)sender forEvent:(UIEvent*)event {
    
	if (event) {
		if (event.type == UIEventTypeTouches) {
			UITouch* touch = [[event allTouches] anyObject];

			if (touch == nil || touch.phase == UITouchPhaseEnded) {
                
                // Recording only current page transist
                [UTestTools recordFrom:self command:UTTCommandSelectPage
                                  args:[NSArray arrayWithObject:[NSString stringWithFormat:@"%d", self.currentPage + 1]]];
            }
        }
        return;
    }
}
@end
