/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIImageView+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"

@implementation UIImageView (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentImage;
}


- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
    
    UITouch* touch = [touches anyObject];
    
    if (touch.phase == UITouchPhaseEnded) {
        UTTCommandEvent* command = [[UTestTools sharedUTester] lastCommandPosted];
        
        if ([command.command isEqualToString:UTTCommandDrag]) {
            [UTestTools recordFrom:self command:UTTCommandDrag args:command.args];
            [[UTestTools sharedUTester].commands removeAllObjects];
        }
        else
            [super handleUTesterTouchEvent:touches withEvent:event];
     }
    else
        [super handleUTesterTouchEvent:touches withEvent:event];
}


@end
