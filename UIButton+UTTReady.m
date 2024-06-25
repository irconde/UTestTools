/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIButton+UTTReady.h"
#import "UIView+UTTReady.h"
#import "UTTOrdinalView.h"

#import <UIKit/UIEvent.h>


@implementation UIButton (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentButton;
}

- (NSString *) baseUTesterID {
	if (self.currentTitle && self.currentTitle.length>0) {
		return self.currentTitle;
	}
    return [super baseUTesterID];
}

+ (NSArray *)aliased {
    if (self == [UIButton class]) {
        return [NSArray arrayWithObjects:@"UINavigationItemButtonView", @"UINavigationButton", @"UIThreePartButton", @"UIRoundedRectButton", @"UIToolbarTextButton", @"UIAlertButton", @"_UIModalItemTableViewCell", nil];
    }
    return nil;
}

- (BOOL) shouldRecordUTester:(UITouch *)touch {
	if ([self.superview isKindOfClass:[UITextField class]]) {
		
        UITextField *textField = (UITextField *)self.superview;
        UITextFieldViewMode tfClearMode = [textField clearButtonMode];
        
        
        if ([textField.text length] > 0 && 
            ((!textField.isEditing && tfClearMode == UITextFieldViewModeUnlessEditing) || 
            (textField.isEditing && tfClearMode == UITextFieldViewModeWhileEditing) ||
            tfClearMode == UITextFieldViewModeAlways))
            return NO;
	}
	return [super shouldRecordUTester:touch];
}


@end
