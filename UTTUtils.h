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
#import "NSRegularExpression+UTestTools.h"


/**
 Clase que proporciona un conjunto de funcionalidades de soporte a la librer&iacture;a.
 */
@interface UTTUtils : NSObject {

}

+ (UIWindow*) rootWindow;
+ (UIView*) findFirstUTesterView:(UIView*)current;

+ (void) shake;
+ (BOOL) isKeyboard:(UIView*)view;
+ (NSString*) className:(NSObject*)ob;
+ (void) rotate:(UIInterfaceOrientation)orientation;
+ (NSString *)timeStamp;
+ (BOOL) isOs5Up;
+ (BOOL) shouldRecord:(NSString *)classString view:(UIView *)current;



@end
