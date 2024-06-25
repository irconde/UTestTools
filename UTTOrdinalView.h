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
#import "UTestTools.h"

@interface UTTOrdinalView : NSObject {
    
}

+ (NSMutableArray *) foundComponents;
+ (NSInteger) componentOrdinalForView:(UIView *)view withUTesterID:(NSString *)uTesterID;
+ (void) sortFoundComponents;

+ (UIView*) buildFoundComponentsStartingFromView:(UIView*)current havingClass:(NSString *)classString isOrdinalMid:(BOOL)ordinal;
+ (UIView*) buildFoundComponentsStartingFromView:(UIView*)current havingClass:(NSString *)classString isOrdinalMid:(BOOL)ordinal skipWebView:(BOOL)skipWebView;


@end
