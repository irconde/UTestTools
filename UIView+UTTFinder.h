/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <UIKit/UIKit.h>
#import "UTTCommandEvent.h"


/**
 Extensi&oacute;n de la clase UIView para facilitar la b&uacute;squeda de los componentes
 */
@interface UIView (UTTFinder)
- (void)constructComponentTree:(NSMutableArray *)tree;

/**
 Obtenci&oacute;n el objeto UIView sobre el que se ha producido un determinado evento.
*/
+ (UIView *)findViewFromEvent:(UTTCommandEvent *)event;

/**
 Obtenci&oacute;n un listado ordenado de todos los componentes de interfaz existentes en una vista. Se considera como primer elemento &aacute;quel situado en el extremo superior izquierdo.
 */
+ (NSArray *)orderedViews;

/**
 Obtenci&oacute;n un listado ordenado de todos los componentes de interfaz existentes en una vista y cuyo identificador coincida con el proporcionado como par&aacute;metro de entrada.
 */
+ (NSArray *)orderedViewsWithUTesterId:(NSString *)uTesterId;

@end
