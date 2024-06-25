/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UITapGestureRecognizer+UTTReady.h"
#import <objc/runtime.h>
#import "UTestTools.h"
#import "UTTUtils.h"

@implementation UITapGestureRecognizer (UTTReady)
+ (void)load {
    if (self == [UITapGestureRecognizer class]) {
        Method originalMethod = class_getInstanceMethod(self, @selector(touchesEnded:withEvent:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(utttouchesEnded:withEvent:));
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

- (void) utttouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [self utttouchesEnded:touches withEvent:event];
}

@end
