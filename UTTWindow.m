/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTWindow.h"



@implementation UTTWindow

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
}
@end
