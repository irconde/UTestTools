/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>
#import <UIKit/UISwitch.h>

@interface _UISwitchInternalViewNeueStyle1: UIView

@end
@interface _UISwitchInternalViewNeueStyle1 (UTTReady)

@end

/**
 Extensi&oacute;n de la clase UISwitch.
 */
@interface UISwitch (UTTReady) 
- (void) handleSwitchTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)recordSwitchTap;
- (void)handleSwitchGesture:(UIGestureRecognizer *)recognizer;
+ (UISwitch *)parentSwitchFromInternalView:(UIView *)view;
@end
