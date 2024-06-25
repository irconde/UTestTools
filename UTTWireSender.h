/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>
#import "UTTCommandEvent.h"

/**
 Clase encargada de gestionar la grabaci&oacute;n de los comandos creados a partir de los eventos registrados.
 */
@interface UTTWireSender : NSObject {
    
}

/**
 Grabaci&oacute;n de un nuevo comando con la informaci&oacute;n relativa a un nuevo evento registrado. El nuevo comando (command) se añade a la lista de comandos (commandList) grabados durante la sesi&oacute;n de pruebas.
 */
+ (void) sendRecordEvent:(UTTCommandEvent *)command;

/**
 Env&iacute;o de todos los datos grabados durante la sesi&oacute;n de pruebas a una base de datos remota MongoDB ubicada en la direcci&oacute;n IP (IPserver) proporcionada como par&aacute;metro de entrada.
 */
+ (void) sendDataToAddress: (NSString *)IPserver;

/**
 Env&iacute;o de todos los datos grabados durante la sesi&oacute;n de pruebas a un servidor localhost. Este m&eacute;todo nos permite trabajar con un host local para comprobar la correcta conexi&oacute;n con una base de datos MongoDB y el correcto env&iacute;o de la informaci&oacute;n codificada en BSON a la misma.
 */
+ (void) sendDataToLocalhost;

/**
 Grabaci&oacute;n de un fichero con codificaci&oacute;n JSON con toda la informaci&oacute;n recopilada durante la sesi&oacute;n de pruebas.
 */
+ (void) saveToJSON: (NSDictionary *)dict;

/**
 Creaci&oacute;n de un diccionario de datos con toda la informaci&oacute;n recopilada durante la sesi&oacute;n de pruebas. Traducimos la lista de objetos UTTCommandEvent a un formato m&aacute;s propicio para su posterior codificaci&oacute;n a JSON y BSON.
 */
+ (NSDictionary *) commandsToDict;

@end
