/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>

/**
 Extensi&oacute;n de la clase NSObject.
 */
@interface NSObject (UTTReady)
- (void) interceptMethod:(SEL)orig withMethod:(SEL)repl ofClass:(Class)class renameOrig:(SEL)newName types:(char*) types;
- (BOOL) uttHasMethod:(SEL) selector;
- (void) interceptMethod:(SEL)orig withClass:(Class)class types:(char*) types;
+ (void) load;
+ (void) swizzle:(NSString *)original with:(NSString *)new for:(Class)forClass;
@end
