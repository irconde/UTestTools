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

@interface UTTRotateCommand : NSObject {
    
}

+ (void) rotate:(UTTCommandEvent*)command;
+ (void) recordRotation:(NSNotification *)notification;
+ (NSString *) rotateDirectionFrom:(UIDeviceOrientation)startOrientation to:(UIDeviceOrientation)endOrientation;

@end
