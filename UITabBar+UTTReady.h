/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */


#import <Foundation/Foundation.h>
#import <UIKit/UITabBar.h>
#import "UTTCommandEvent.h"

/**
 Extensi&oacute;n de la clase UITabBar.
 */
@interface UITabBar (UTTReady)
- (void) handleTabBar:(UITabBar *)tabBar;
@end