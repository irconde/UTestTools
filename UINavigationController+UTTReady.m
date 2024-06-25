/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UINavigationController+UTTReady.h"
#import <objc/runtime.h>
#import "UTestTools.h"
#import "NSObject+UTTReady.h"

@implementation UINavigationController (UTTReady)

+ (void)load {
    if (self == [UINavigationController class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(pushViewController:animated:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttpushViewController:animated:));
        method_exchangeImplementations(originalMethod, replacedMethod);
        
        Method originalMethod2 = class_getInstanceMethod(self, @selector(popViewControllerAnimated:));
        Method replacedMethod2 = class_getInstanceMethod(self, @selector(uttpopViewControllerAnimated:));
        method_exchangeImplementations(originalMethod2, replacedMethod2);
    }
}

- (void) uttpushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([[UTestTools sharedUTester].commandSpeed doubleValue] < 333333 && [UTestTools sharedUTester].commandSpeed)
        animated = NO;
    
    [self uttpushViewController:viewController animated:animated];

}


- (UIViewController *) uttpopViewControllerAnimated:(BOOL)animated
{
    if ([UTestTools sharedUTester].commandSpeed && [[UTestTools sharedUTester].commandSpeed doubleValue] < 333333)
        animated = NO;

    [self uttpopViewControllerAnimated:animated];
    
    return self;
}

@end
