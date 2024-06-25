/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTRotateCommand.h"
#import "UTestTools.h"
#import "UTTUtils.h"
#import "NSString+UTestTools.h"

@interface  UTTRotateCommand() 
+ (UIDeviceOrientation) rotationOrientationFrom:(UIDeviceOrientation)startOrientation withDirection:(NSString *)direction;
+ (NSString *) rotateDirectionFrom:(UIDeviceOrientation)startOrientation to:(UIDeviceOrientation)endOrientation;
@end

@implementation UTTRotateCommand

static NSString *leftArg = @"Left";
static NSString *rightArg = @"Right";

+ (void) rotate:(UTTCommandEvent*)command {
    UTestTools *uTester = [UTestTools sharedUTester];
    UIInterfaceOrientation orientation = uTester.currentOrientation;
    
    if ([command.args count] != 1) {
        command.lastResult = [NSString stringWithFormat:@"Requiere 1 argumento, pero tiene %d", [command.args count]];
        return;
    } else if (![[command.args objectAtIndex:0] isEqualToString:leftArg] &&
               ![[command.args objectAtIndex:0] isEqualToString:rightArg]) {
        command.lastResult = [NSString stringWithFormat:@"%@ no es un argumento disponible para Device Rotate — usa %@ o %@", [command.args objectAtIndex:0], leftArg, rightArg];
        return;
    }
    
    orientation = [[self class] rotationOrientationFrom:orientation withDirection:(NSString*)[command.args objectAtIndex:0]];
			
	[UTTUtils rotate:orientation];
}

+ (void) recordRotation:(NSNotification *)notification {
    UTestTools *uTester = [UTestTools sharedUTester];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == 0) {
        return;
    }
    
    if (orientation == uTester.currentOrientation) {
        return;
    }
    
    NSString *rotationDirection = [[self class] rotateDirectionFrom:uTester.currentOrientation to:orientation];
    
    uTester.currentOrientation = orientation;
    
    if (rotationDirection == nil)
        return;
    
    [UTestTools recordFrom:nil command:UTTCommandRotate args:[NSArray arrayWithObject:rotationDirection]];
}

+ (UIDeviceOrientation) rotationOrientationFrom:(UIDeviceOrientation)startOrientation withDirection:(NSString *)direction {
    UIDeviceOrientation endOrientation = startOrientation;
    BOOL isLeft = [direction isEqualToString:leftArg ignoreCase:YES];
    BOOL isRight = [direction isEqualToString:rightArg ignoreCase:YES];
    
    if (startOrientation == UIDeviceOrientationPortrait) {
        if (isLeft)
            endOrientation = UIDeviceOrientationLandscapeLeft;
        else if (isRight)
            endOrientation = UIDeviceOrientationLandscapeRight;
    } else if (startOrientation == UIDeviceOrientationPortraitUpsideDown) {
        if (isLeft)
            endOrientation = UIDeviceOrientationLandscapeRight;
        else if (isRight)
            endOrientation = UIDeviceOrientationLandscapeLeft;
    } else if (startOrientation == UIDeviceOrientationLandscapeRight) {
        if (isLeft)
            endOrientation = UIDeviceOrientationPortrait;
        else if (isRight)
            endOrientation = UIDeviceOrientationPortraitUpsideDown;
    } else if (startOrientation == UIDeviceOrientationLandscapeLeft) {
        if (isLeft)
            endOrientation = UIDeviceOrientationPortraitUpsideDown;
        else if (isRight)
            endOrientation = UIDeviceOrientationPortrait;
    }
    
    return endOrientation;
}

+ (NSString *) rotateDirectionFrom:(UIDeviceOrientation)startOrientation to:(UIDeviceOrientation)endOrientation {
    NSString *rotationDirection = nil;
    NSString *leftString = leftArg;
    NSString *rightString = rightArg;
    
    if (startOrientation == UIDeviceOrientationPortrait) {
        if (endOrientation == UIDeviceOrientationLandscapeLeft)
            rotationDirection = leftString;
        else if (endOrientation == UIDeviceOrientationLandscapeRight)
            rotationDirection = rightString;
    } else if (startOrientation == UIDeviceOrientationPortraitUpsideDown) {
        if (endOrientation == UIDeviceOrientationLandscapeRight)
            rotationDirection = leftString;
        else if (endOrientation == UIDeviceOrientationLandscapeLeft)
            rotationDirection = rightString;
    } else if (startOrientation == UIDeviceOrientationLandscapeRight) {
        if (endOrientation == UIDeviceOrientationPortrait)
            rotationDirection = leftString;
        else if (endOrientation == UIDeviceOrientationPortraitUpsideDown)
            rotationDirection = rightString;
    } else if (startOrientation == UIDeviceOrientationLandscapeLeft) {
        if (endOrientation == UIDeviceOrientationPortraitUpsideDown)
            rotationDirection = leftString;
        else if (endOrientation == UIDeviceOrientationPortrait)
            rotationDirection = rightString;
    }
    
    return rotationDirection;
}
@end
