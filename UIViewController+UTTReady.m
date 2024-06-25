/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */


#import "UIViewController+UTTReady.h"
#import "UTestTools.h"
#import "NSObject+UTTReady.h"

@implementation UIViewController (UTTReady)
+ (void)load {
    if (self == [UIViewController class]) {
        [NSObject swizzle:@"viewDidAppear:" with:@"uttViewDidAppear:" for:self];
    }
}

- (void)uttViewDidAppear:(BOOL)animated {
    [self uttViewDidAppear:animated];
}
@end
