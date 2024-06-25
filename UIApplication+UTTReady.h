/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>

/**
 Extensi&oacute;n de la clase UIApplication.
 */
@interface UIApplication (UTTReady)

/**
 Registro de informaci&oacute;n general relativa al contexto en que se produce la sesi&oacute;n de pruebas. 
 Esta informaci&oacute;n consiste en una marca temporal del comienzo de sesi&oacute;n, la versi&oacute;n usada de la librer&iacute;a, el sistema operativo bajo el que corre la aplicaci&oacute;n monitorizada, el dispositivo f&iacute;sico utilizado para llevar a cabo la sesi&oacute;n y el c&oacute;digo de identificaci&oacute;n del dispositivo.
 */
+ (void) initUTestTools:(NSNotification*)notification;

@end
