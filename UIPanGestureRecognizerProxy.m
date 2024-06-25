/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIPanGestureRecognizerProxy.h"

@implementation UIPanGestureRecognizerProxy
@synthesize location, uttView;

- (CGPoint)locationInView:(UIView *)view {
    CGPoint point = [uttView convertPoint:location toView:view];
    return point;
}

@end
