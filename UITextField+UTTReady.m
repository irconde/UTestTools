/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UITextField+UTTReady.h"

#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import "UIControl+UTTready.h"
#import "UTestTools.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "NSObject+UTTReady.h"
#import "NSString+UTestTools.h"
#import "UTTOrdinalView.h"


@interface UITextField (UTT_INTERCEPTOR)
- (BOOL) orig_textFieldShouldReturn:(UITextField*)textField;
- (BOOL) orig_textFieldShouldClear:(UITextField*)textField;
- (BOOL) orig_textFieldShouldEndEditing:(UITextField*)textField;
- (void) orig_textFieldDidEndEditing:(UITextField*)textField;
- (BOOL) orig_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end

@interface UTTDefaultTextFieldDelegate : NSObject <UITextFieldDelegate>
@end
@implementation UTTDefaultTextFieldDelegate
@end


@implementation UITextField (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentInput;
}

+ (void)load {
    if (self == [UITextField class]) {
        Method originalMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttSetDelegate:));
        method_exchangeImplementations(originalMethod, replacedMethod);	
    }
}
		 
- (void) uttAssureAutomationInit {
	[super uttAssureAutomationInit];
    
    if (self.class != NSClassFromString(@"UIAlertSheetTextField")) {
        if (!self.delegate) {
            UTTDefaultTextFieldDelegate *del = [[UTTDefaultTextFieldDelegate alloc] init];
            self.delegate = del;
        }
    }
}


- (void) uttSetDelegate:(NSObject <UITextFieldDelegate>*) del {  
	[del interceptMethod:@selector(textFieldShouldReturn:) withClass:[self class] types:"c@:@"];
	[del interceptMethod:@selector(textFieldShouldEndEditing:) withClass:[self class] types:"v@:@"];	
	[del interceptMethod:@selector(textFieldDidEndEditing:) withClass:[self class] types:"v@:@"];	
	[del interceptMethod:@selector(textField:shouldChangeCharactersInRange:replacementString:) withClass:[self class] types:"c@:@@@"];	
	[del interceptMethod:@selector(textFieldShouldClear:) withClass:[self class] types:"c@:@"];
	
	[self uttSetDelegate:del];
	
}

- (NSString*) baseUTesterID {
	if (self.placeholder && self.placeholder.length>0) {
	    return self.placeholder;
	}
    return [super baseUTesterID];
}


- (BOOL)utt_textFieldShouldReturn:(UITextField *)textField {
	if ([UTestTools sharedUTester].isWireRecording) {
		
        UTTCommandEvent* lastEvent = [[UTestTools sharedUTester] lastCommand];
		if (([lastEvent.command isEqualToString:UTTCommandInputText] || [lastEvent.command isEqualToString:UTTCommandEnterText ignoreCase:YES]) && [lastEvent.uTesterID isEqualToString:[textField uTesterID]]) {
			[[UTestTools sharedUTester] popCommand];
		}		
        [UTestTools recordFrom:textField command:UTTCommandEnterText args:[NSArray arrayWithObjects: textField.text,
                                                                          @"enter", 
                                                                          nil]];
	}
	if (class_getInstanceMethod([self class], @selector(orig_textFieldShouldReturn:))) {
		return ([self orig_textFieldShouldReturn:textField]);
	} else {
		return YES;
	}
}

- (BOOL)utt_textFieldShouldClear:(UITextField *)textField {
	if ([UTestTools sharedUTester].isWireRecording) {
				
        [UTestTools recordFrom:textField command:UTTCommandClear];
	}
	if (class_getInstanceMethod([self class], @selector(orig_textFieldShouldClear:))) {
		return [self orig_textFieldShouldClear:textField];
	} else {
		return YES;
	}
}

- (BOOL)utt_textFieldShouldEndEditing:(UITextField *)textField {

	if (class_getInstanceMethod([self class], @selector(orig_textFieldShouldEndEditing:))) {
		return ([self orig_textFieldShouldEndEditing:textField]);
	} else {
		return YES;
	}
}

- (void)utt_textFieldDidEndEditing:(UITextField *)textField {
	
	if (class_getInstanceMethod([self class], @selector(orig_textFieldDidEndEditing:))) {
		[self orig_textFieldDidEndEditing:textField];
	}
}

- (BOOL) utt_textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([UTestTools sharedUTester].isWireRecording) {
		
        if ([UTestTools sharedUTester].isWireRecording) {
			UTTCommandEvent* lastEvent = [[UTestTools sharedUTester] lastCommand];
			if (([lastEvent.command isEqualToString:UTTCommandInputText] || 
                 [lastEvent.command isEqualToString:UTTCommandEnterText ignoreCase:YES]) && [lastEvent.uTesterID isEqualToString:[textField uTesterID]]) {
				[[UTestTools sharedUTester] popCommand];
			}
			NSString* newVal = [textField.text stringByReplacingCharactersInRange:range withString:string];
			[ [UTestTools sharedUTester] recordFrom:textField command:UTTCommandEnterText 
											  args:[NSArray arrayWithObjects: newVal, nil]
											  post:NO];
		}		
	}
	if (class_getInstanceMethod([self class], @selector(orig_textField:shouldChangeCharactersInRange:replacementString:))) {
		return [self orig_textField:textField shouldChangeCharactersInRange:range replacementString:string];
	} else {
		return YES;
	}

}

@end
