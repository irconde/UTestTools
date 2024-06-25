/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIStepper+UTTReady.h"
#import "UTestTools.h"
#import "NSString+UTestTools.h"
#import "UIView+UTTReady.h"
#import "UTTConvertType.h"
#import "UTTCommandEvent.h"

@implementation UIStepper (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentStepper;
}


- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    // Grabar el evento sólo en la fase en que el tap termina
    
    if (touch.phase == UITouchPhaseEnded) {
        // Encontrar qué botón está siendo tocado basándonos en la ubicación del tap
       
        for (UIButton *button in self.subviews) {
            CGRect buttonRect = button.frame;
            
            if (CGRectContainsPoint(button.frame, location)) {
                NSString *command;
                
                // Definimos el comando en base a la label de accesibilisada de los botones (incremento/decremento)
                if ([[button uTesterID] isEqualToString:UTTCommandIncrement ignoreCase:YES]) {
                    
                    command = UTTCommandIncrement;
                } else if ([[button uTesterID] isEqualToString:UTTCommandDecrement ignoreCase:YES]) {
                    command = UTTCommandDecrement;
                }
                
                if (button.enabled)
                    // Record command for stepper
                    [UTestTools recordFrom:self command:command];
            }
        }
    }
}

@end
