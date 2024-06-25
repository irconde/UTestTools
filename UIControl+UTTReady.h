/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>

/**
 Extensi&oacute;n de UIControl para la gesti&oacute;n de eventos. Se sobreescribir&aacute;n para modificar 
 c&oacute;mo UIControl graba UIControlEvents.
 */

@interface UIControl (UTTReady)

/**
 Los eventos que deseamos grabar para la clase UIControl. Por defecto, no grabaremos ninguno.
 */
- (UIControlEvents)uTestEventsToHandle;

/**
 Prepara un evento UIControlEvent para la grabaci&oacute;n
 */
- (void) handleUTesterEventFromSender:(id)sender forEvent:(UIEvent*)event;

/**
 Registro de los eventos que van a ser grabados
 */
- (void) subscribeToUTesterEvents;

@end
