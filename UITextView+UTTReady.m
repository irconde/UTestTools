/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UITextView+UTTReady.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import "NSObject+UTTReady.h"
#import "NSString+UTestTools.h"

@interface UITextView (UTT_INTERCEPTOR)
- (BOOL)orig_textViewShouldEndEditing:(UITextView *)textView;
- (BOOL) orig_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string;
- (void) orig_setDelegate:(NSObject <UITextViewDelegate>*) del;
@end

@interface UTTDefaultTextViewDelegate : NSObject <UITextViewDelegate>
@end
@implementation UTTDefaultTextViewDelegate
@end

@implementation UITextView (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentTextArea;
}

+ (void)load {
    if (self == [UITextView class]) {
		
		[UIScrollView interceptMethod:@selector(setDelegate:) withClass:[UITextView class] types:"v@:@"];
    }
}

- (void) uttAssureAutomationInit {
    
//	[super uttAssureAutomationInit];
//    
//    if (!self.delegate) {
//        UTTDefaultTextViewDelegate *del = [[UTTDefaultTextViewDelegate alloc] init];
//		self.delegate = del;
//    }
    
}

- (void) utt_setDelegate:(NSObject <UITextViewDelegate>*) del {	

		[del interceptMethod:@selector(textViewShouldEndEditing:) withClass:[self class] types:"c@:@"];	
		[del interceptMethod:@selector(textViewShouldBeginEditing:) withClass:[self class] types:"c@:@"];			
		[del interceptMethod:@selector(textView:shouldChangeTextInRange:replacementText:) withClass:[self class] types:"c@:@@@"];
    
	[self orig_setDelegate:del];

	
}


- (BOOL)utt_textViewShouldEndEditing:(UITextView *)textView {
	if ([UTestTools sharedUTester].isWireRecording) {

		UTTCommandEvent* lastEvent = [[UTestTools sharedUTester] lastCommand];
		if (!([lastEvent.command isEqualToString:UTTCommandInputText] || 
              [lastEvent.command isEqualToString:UTTCommandEnterText ignoreCase:YES])) {
			[[UTestTools sharedUTester] recordFrom:textView command:UTTCommandEnterText 
										  args:[NSArray arrayWithObjects: textView.text, @"true", nil]
										  post:NO];

		} else {
			if (([lastEvent.command isEqualToString:UTTCommandInputText] || 
                 [lastEvent.command isEqualToString:UTTCommandEnterText ignoreCase:YES]) && 
                [lastEvent.uTesterID isEqualToString:[textView uTesterID]]) {
				[[UTestTools sharedUTester] popCommand];
			}
			[ [UTestTools sharedUTester] recordFrom:textView command:UTTCommandEnterText 
											  args:[NSArray arrayWithObjects: textView.text, @"true", nil]
											  post:NO];
		}
	}
	if (class_getInstanceMethod([self class], @selector(utt_textViewShouldEndEditing:))) {
		return ([(UITextView *)self.delegate utt_textViewShouldEndEditing:textView]);
	} else {
		return YES;
	}
}

- (BOOL) utt_textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
	if ([UTestTools sharedUTester].isWireRecording) {
		UTTCommandEvent* lastEvent = [[UTestTools sharedUTester] lastCommand];
		if (([lastEvent.command isEqualToString:UTTCommandInputText] || 
             [lastEvent.command isEqualToString:UTTCommandEnterText ignoreCase:YES]) 
            && [lastEvent.uTesterID isEqualToString:[textView uTesterID]]) {
			[[UTestTools sharedUTester] popCommand];
		}
		NSString* newVal = [textView.text stringByReplacingCharactersInRange:range withString:string];
		[ [UTestTools sharedUTester] recordFrom:textView command:UTTCommandEnterText 
										  args:[NSArray arrayWithObjects: newVal, nil]
										  post:NO];
	}
	if (class_getInstanceMethod([self class], @selector(utt_textView:shouldChangeTextInRange:replacementText:))) {
		return [(UITextView *)self.delegate utt_textView:textView shouldChangeTextInRange:range replacementText:string];
	} else {
		return YES;
	}
	
}

- (BOOL) shouldRecordUTester:(UITouch*)touch {
	return (touch.phase == UITouchPhaseEnded);
}


@end
