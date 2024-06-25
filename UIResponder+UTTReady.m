/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIResponder+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "UIView+UTTReady.h"


@implementation UIResponder (UTTReady)

+ (void)load {
    if (self == [UIResponder class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(becomeFirstResponder));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttbecomeFirstResponder));
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

- (BOOL)uttbecomeFirstResponder
{
    if ([self class] == [UITextField class])
    {
        UITextField *view = (UITextField *)self;
        
        if (view != nil)
            [view uttAssureAutomationInit];
    } else if ([self class] == [UITextView class])
    {
        UITextView *view = (UITextView *)self;
        
        if (view != nil)
            [view uttAssureAutomationInit];
    }
    
    [self uttbecomeFirstResponder];
    return YES;
}

@end
