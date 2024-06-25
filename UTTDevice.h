/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UTTCommandEvent.h"

/**
 Clase usada para obtener informaci&oacute;n del dispositivo f&iacute;sico sobre el que se ejecuta la App.
 */
@interface UTTDevice : NSObject{
    
}

/**
 Devuelve una cadena de texto con el sistema operativo utilizado por el dispositivo. En la versi&oacute;n de UITextTools para iOS devolver&aacute; por tanto la cadena "iOS"
 */
+ (NSString *) os;

/**
 Devuelve una cadena de texto con el modelo del dispositivo f&iacute;sico utilizado.
 */
+ (NSString *) getDeviceModel;

/**
 Devuelve una cadena de texto con la versi&oacute;n de sistema operativo utilizado por el dispositivo.
 */
+ (NSString *) getOSVersion;

/**
 Devuelve una cadena de texto con el identificador &uacute;nico del dispositivo.
 */
+ (NSString *) getUDID;

@end
