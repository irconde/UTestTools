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
#import "UIView+UTTFinder.h"
#import "UTTConvertType.h"
@class UTTCommandEvent;

/**
 Extensi&oacute;n de UIView que permite la grabaci&oacute;n de eventos de toque y movimiento. Las subvistas de UIView pueden sobreescribir uno o m&aacute;s de estos m&eacute;todos para personalizar la l&oacute;gica de grabaci&oacute;n para una determinada clase.
 */

@interface UIView (UTTReady)

/**
 Devuelve una cadena de texto que identifica de forma inequ&iacute;voca una instancia de la clase de este componente.
 */
- (NSString*) uTesterID;
- (NSString *) baseUTesterID;
- (NSInteger) uttOrdinal;
- (NSArray *) rawUTesterIDCandidates;

/**
 Devuelve el valor booleano YES en caso de que el toque captado deba ser registrado. Por defecto, devuelve YES si touch.phase== UITouchPhaseEnded y NO en caso contrario. En este m&eacute;todo es donde filtramos qu&eacute; eventos t&aacute;ctiles deseamos registrar para una determinada clase.
 */
- (BOOL) shouldRecordUTester:(UITouch*)touch;

/**
 Eval&uacute;a los eventos de toque y graba el comando correspondiente.
 */
- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event;

- (void) handleUTesterMotionEvent:(UIEvent*)event;

/**
 Devuelve NO en caso de que no deseen grabar los comandos para un determinado componente. Por defecto, devuelve YES para las subclases de UIView y NO para las instancias de la clase UIView (debido a que &eacute;stas son contenedores de otros componentes).
 */
- (BOOL) isUTTEnabled;
- (BOOL) swapsWith:(NSString*)className;
- (void) uttAssureAutomationInit;
- (BOOL) hasUTesterIdAssigned;
- (NSString *) keyForUTesterId;

@end
