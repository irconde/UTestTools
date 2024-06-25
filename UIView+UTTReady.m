/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIView+UTTReady.h"
#import "UISwitch+UTTReady.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UTTCommandEvent.h"
#import "UTestTools.h"
#import "UIControl+UTTready.h"
#import "UTTUtils.h"
#import "UITabBarButtonProxy.h"
#import "UIToolbarTextButtonProxy.h"
#import "UIPushButtonProxy.h"
#import "UISegmentedControlProxy.h"
#import "UITableViewCellContentViewProxy.h"
#import "NSString+UTestTools.h"
#import "UTTOrdinalView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIGestureRecognizerProxy.h"
#import "UIGestureRecognizer+UTTReady.h"
#import "UTTConvertType.h"
#import "NSRegularExpression+UTestTools.h"
#import "UITabBar+UTTReady.h"

@implementation UIView (UTTReady)
static NSArray* privateClasses;
static NSArray* ignoreClasses;

+ (void)load {
	if (self == [UIView class]) {
		
        // Clases privadas que reciben eventos UI, pero la correspondiente clase pública es una superclase. Grabamos el evento en la superclase que es pública
        
        privateClasses = [[NSArray alloc] initWithObjects:@"UIPickerTable", @"UITableViewCellContentView",
						  @"UITableViewCellDeleteConfirmationControl", @"UITableViewCellEditControl", @"UIAutocorrectInlinePrompt", nil];
        ignoreClasses = [[NSArray alloc] initWithObjects:@"UIPickerTableViewWrapperCell", @"_UIWebViewScrollView",
                         @"UIWebBrowserView", @"UITextEffectsWindow", @"UIPickerTableViewTitledCell",
                         @"_UISwitchInternalViewNeueStyle1",@"UITextView", nil];
		
        Method originalMethod = class_getInstanceMethod(self, @selector(initWithFrame:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttInitWithFrame:));
        method_exchangeImplementations(originalMethod, replacedMethod);
        
        Method gestureMethodOriginal = class_getInstanceMethod(self, @selector(addGestureRecognizer:));
        Method gestureMethodReplaced = class_getInstanceMethod(self, @selector(uttAddGestureRecognizer:));
        method_exchangeImplementations(gestureMethodOriginal, gestureMethodReplaced);
	}
}

- (void) uttAssureAutomationInit {
    
}

- (id)uttInitWithFrame:(CGRect)aRect {
	
	[self uttInitWithFrame:aRect];
	if (self) {
		if ([self isKindOfClass:[UIControl class]]) {
			[(UIControl*)self performSelector:@selector(subscribeToUTesterEvents)];
		}
	}
	
	return self;
	
}

- (BOOL)shouldIgnoreTouch {
    for (NSString *class in ignoreClasses) {
        
        // Ignoramos taps en picker cell
        // Ignoramos componentes web
        // Ignoramos taps en el teclado y en otras ventanas de superposición
        if ([self isKindOfClass:objc_getClass([class UTF8String])]) {
            return YES;
        }
    }
    return NO;
}


- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
    
    if ([self shouldIgnoreTouch]) {
        NSLog(@"Ignorar: %@",self);
        return;
    }
    
    if ([self isKindOfClass:[UIButton class]] &&
        [self.superview isKindOfClass:[UITableViewCell class]]) {
        
        UITouch* touch = [touches anyObject];
        UITableViewCell *cell = (UITableViewCell *)self.superview;
        UITableView *tableView = (UITableView *)cell.superview;
        NSString *row = [NSString stringWithFormat:@"%i",[tableView indexPathForCell:cell].row +1];
        NSString *section = [NSString stringWithFormat:@"%i",[tableView indexPathForCell:cell].section +1];
        NSMutableArray *args = [[NSMutableArray alloc] init];
        
        [args addObject:row];
        
        if ([tableView indexPathForCell:cell].section > 0)
            [args addObject:section];
        
        if (touch.phase == UITouchPhaseEnded)
            [UTestTools recordFrom:tableView command:UTTCommandSelectIndicator args:args];
        
        return;
    }else if ([self isKindOfClass:objc_getClass("UITableViewCellReorderControl")]) {
        
        return;
    } else {
		
		UITouch* touch = [touches anyObject];
        
        
		if (touch.phase == UITouchPhaseMoved) {
            if ([self isKindOfClass:objc_getClass("UITableViewCellContentView")]) {
                return;
            }
            if (!([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UITextView class]])) {
                CGPoint loc = [touch locationInView:self];
                UTTCommandEvent* command = [[UTestTools sharedUTester] lastCommandPosted];
                if (([command.command isEqualToString:UTTCommandMove ignoreCase:YES]  ||
                     [command.command isEqualToString:UTTCommandDrag ignoreCase:YES])
                    && [command.uTesterID isEqualToString:[self uTesterID]]) {
                    [[UTestTools sharedUTester] deleteCommand:[[UTestTools sharedUTester] commandCount] - 1];
                    NSMutableArray* args = [NSMutableArray arrayWithArray:command.args];
                    [args addObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", loc.x],
                                               [NSString stringWithFormat:@"%1.0f", loc.y],
                                               nil]];
                    
                    UTTCommandEvent *moveEvent = [[UTTCommandEvent alloc]
                                                 init:UTTCommandDrag className:[NSString stringWithUTF8String:class_getName([self class])]
                                                 uTesterID:[self uTesterID]
                                                 args:args];
                    
                    [UTestTools buildCommand:moveEvent];
                    
                
                    return;
                }
                
                else {
                    
                    
                    NSMutableArray* args = [NSMutableArray arrayWithArray:command.args];
                    [args addObjectsFromArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%1.0f", loc.x],
                                               [NSString stringWithFormat:@"%1.0f", loc.y],
                                               nil]];
                    
                    UTTCommandEvent *moveEvent = [[UTTCommandEvent alloc]
                                                 init:UTTCommandDrag className:[NSString stringWithUTF8String:class_getName([self class])]
                                                 uTesterID:[self uTesterID]
                                                 args:args];
                    
                    [UTestTools buildCommand:moveEvent];
                    return;
                }
            }
		} else if (touch.phase == UITouchPhaseBegan) {
            
            if ([self.superview isKindOfClass:objc_getClass("UIPickerTableViewTitledCell")]) {
                [UTestTools sharedUTester].currentTapCommand = nil;
                return;
            }
            
            
            else if ([self.superview isKindOfClass:objc_getClass("UITableViewCell")])
            {
                [UTestTools sharedUTester].currentTapCommand = nil;
                return;
            }
            else
            {
                
                [UTestTools sharedUTester].currentTapCommand = [[UTTCommandEvent alloc]
                                                               init:UTTCommandTap className:[NSString stringWithUTF8String:class_getName([self class])]
                                                               uTesterID:[self uTesterID]
                                                               args:nil];
                return;
            }
            
                                                                   
        } else if (touch.phase == UITouchPhaseCancelled) {
            [UTestTools sharedUTester].currentTapCommand = nil;
        } else if (touch.phase == UITouchPhaseEnded) {
            
            CGPoint loc = [touch locationInView:self];
            NSUInteger touchCount = [touch tapCount];
            
            if ([self.superview isKindOfClass:objc_getClass("UITableViewCellScrollView")]) {
                // ios 7 UITableViewCellContentView
                UITableViewCell *cell = (UITableViewCell *)self;
                while (![cell isKindOfClass:[UITableViewCell class]]) {
                    if (!self.superview) {
                        break;
                    }
                    cell = (UITableViewCell *)cell.superview;
                }
                
                [cell handleUTesterTouchEvent:touches withEvent:event];
                [UTestTools sharedUTester].currentTapCommand = nil;
                return;
            }
            
            
            if ([self.superview isKindOfClass:objc_getClass("UIPickerTableViewTitledCell")]) {
                [UTestTools sharedUTester].currentTapCommand = nil;
                return;
            }
            
            else if ([self.superview isKindOfClass:objc_getClass("UITableViewCell")])
            {
                [self.superview handleUTesterTouchEvent:touches withEvent:event];
                [UTestTools sharedUTester].currentTapCommand = nil;
                return;
            }
            
            // Handle Tap
            
            NSMutableArray* args = nil;
            if (touch.tapCount == 1 || touch.tapCount == 2) {
                args = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%1.0d", touch.tapCount]];
            }
            
            
            
            if ([self isKindOfClass:objc_getClass("UITabBarButton")]) {
                UITabBarButtonProxy* but = (UITabBarButtonProxy *)self;
                NSString* label = nil;
                UILabel *buttonLabel = [UTTUtils isOs5Up] ? nil : (UILabel *)but->_label;
                
                if (![UTTUtils isOs5Up] && [buttonLabel respondsToSelector:@selector(text)]) {
                    UILabel *buttonLabel = (UILabel *)but->_label;
                    label = [buttonLabel text];
                } else {
                    for (UILabel *foundLabel in [but subviews]) {
                        
                        if ([foundLabel isKindOfClass:objc_getClass("UITabBarButtonLabel")])
                            label = foundLabel.text;
                    }
                }
                
                UITabBar *tabBar = (UITabBar *)self.superview;
                
                if ([tabBar isKindOfClass:[UITabBar class]]) {
                    [tabBar handleTabBar:tabBar];
                    return;
                }
                
            } else if ([self isKindOfClass:objc_getClass("UISwitch")] ||
                       [self isKindOfClass:objc_getClass("_UISwitchInternalView")]) {
                UISwitch *aSwitch = nil;
                
                if ([self isKindOfClass:objc_getClass("_UISwitchInternalView")])
                    aSwitch = (UISwitch *)self.superview;
                else
                    aSwitch = (UISwitch *)self;
                
                [aSwitch handleSwitchTouchEvent:touches withEvent:event];
            }
            else {
                UTTCommandEvent* command = [[UTestTools sharedUTester] lastCommandPosted];
                
                if (command.args.count > 0 && [command.command isEqualToString:UTTCommandDrag]) {
                    [UTestTools recordFrom:self command:UTTCommandDrag args:command.args];
                    [[UTestTools sharedUTester].commands removeAllObjects];
                }
                
                // A partir de la beta6 no graba touchDown/touchUp
                
                else
                {
                    switch (touchCount)
                    {
                        case 1:
                            // Registro de las coordenadas del tap
                            args = [NSArray arrayWithObjects:
                                    [NSString stringWithFormat:@"%1.0f",loc.x],
                                    [NSString stringWithFormat:@"%1.0f",loc.y],nil];
                            [self performSelector:@selector(handleSingleTap:) withObject:args afterDelay:.2];
                            break;
                        case 2:
                            args = [NSArray arrayWithObjects:
                                    [NSString stringWithFormat:@"%1.0f",loc.x],
                                    [NSString stringWithFormat:@"%1.0f",loc.y],nil];
                            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleSingleTap:) object:args];
                            [self performSelector:@selector(handleDoubleTap:) withObject:args afterDelay:.2];
                            break;
                            
                        default:
                            break;
                    }
                    
                }
            }
            return;
        }
	}
}

-(void) handleSingleTap: (NSArray *) args
{
    
    if ([UTestTools sharedUTester].currentTapCommand) {

        [UTestTools sendRecordEvent:[UTestTools sharedUTester].currentTapCommand];
        [UTestTools sharedUTester].currentTapCommand = nil;
    } else {
        [UTestTools recordFrom:self command:UTTCommandTap args:args];
    }
}

-(void) handleDoubleTap:(NSArray *) args
{
    [UTestTools recordFrom:self command:UTTCommandDoubleTap args:args];
}

- (void) handleUTesterMotionEvent:(UIEvent*)event {
	[UTestTools recordFrom:nil command:UTTCommandShake];
}

- (BOOL) shouldRecordUTester:(UITouch*)touch {
	// Por defecto sólo registramos la fase TouchEnded
    //	return (touch.phase == UITouchPhaseEnded);
    return YES;
}


- (void) removeView:(UIView *)view {
    [view removeFromSuperview];
}

- (BOOL) isUTTEnabled {
    
    if ([self.gestureRecognizers count] > 0)
        return YES;
	
	for (NSString* className in privateClasses) {
		if ([self isKindOfClass:objc_getClass([className UTF8String])]) {
			return NO;
		}
	}
	
	return ![self isMemberOfClass:[UIView class]] && ![UTTUtils isKeyboard:self];
}

- (NSString *) keyForUTesterId {
    return [NSString stringWithFormat:@"%@",self];
}

- (BOOL) hasUTesterIdAssigned {
    return [[UTestTools sharedUTester].componentUTesterIds objectForKey:[self keyForUTesterId]];
}

- (NSArray*) rawUTesterIDCandidates {
    NSMutableArray* candidates=[NSMutableArray arrayWithCapacity:3];
    
    if ([self respondsToSelector:@selector(accessibilityIdentifier)]) {
        NSString* candidate=self.accessibilityIdentifier;
        if (candidate!= nil && [candidate length] > 0) {
            [candidates addObject:candidate];
        }
    }
    
    if ([self respondsToSelector:@selector(accessibilityLabel)]) {
        NSString* candidate=self.accessibilityLabel;
        if (candidate!= nil && [candidate length] > 0) {
            [candidates addObject:candidate];
        }
    }
    
    if (self.tag !=0) {
        NSString* candidate=[NSString stringWithFormat:@"%ld",(long)self.tag];
        if (candidate!= nil && [candidate length] > 0) {
            [candidates addObject:candidate];
        }
    }
    
    return candidates;
}

- (NSString*) uTesterID {
	NSString *currentID = [self baseUTesterID];
    
    if ([currentID isKindOfClass:NSClassFromString(@"UITextInputTraits")]) {
        return nil;
    }
    
    if ([currentID rangeOfString:@"#utt"].location == 0) {
        NSArray *views = [self.class orderedViews];
        NSInteger ordinal = [views indexOfObject:[NSValue valueWithNonretainedObject:self]]+1;
        return [NSString stringWithFormat:@"#%i",ordinal];
    }
    
    NSArray *views = [self.class orderedViewsWithUTesterId:currentID];
    NSInteger index = [views indexOfObject:[NSValue valueWithNonretainedObject:self]]+1;
    if (index > 1) {
        currentID = [currentID stringByAppendingFormat:@"(%i)",index];
    }
    
	return currentID;
}


- (NSString *) baseUTesterID {
    if ([self isKindOfClass:objc_getClass("UITabBarButton")]) {
		UITabBarButtonProxy* but = (UITabBarButtonProxy *)self;
		NSString* label = nil;
        UILabel *buttonLabel = [UTTUtils isOs5Up] ? nil : (UILabel *)but->_label;
        
        
        if (![UTTUtils isOs5Up] && [buttonLabel respondsToSelector:@selector(text)])
            label = [buttonLabel text];
        else {
            for (UILabel *foundLabel in [but subviews]) {
                
                if ([foundLabel isKindOfClass:objc_getClass("UITabBarButtonLabel")])
                    label = foundLabel.text;
            }
        }
		if (label != nil) {
			return label;
		}	
	} else if ([self isKindOfClass:objc_getClass("UIToolbarTextButton")]) {
		UIToolbarTextButtonProxy* but = (UIToolbarTextButtonProxy *)self;
        
        
		if (![UTTUtils isOs5Up] && [but->_info isKindOfClass:objc_getClass("UIPushButton")]) {
			NSString*label = [(UIPushButtonProxy *)but->_info title];
            
            return label;
		}
        
        for (UIView *found in but.subviews) {
            if ([found isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)found;
                return button.titleLabel.text;
            } else if ([found isKindOfClass:[UILabel class]]) {
                UILabel *l = (UILabel *)found;
                return l.text;
            }
        }
	} else if ([self isKindOfClass:objc_getClass("UITableViewCellContentViewProxy")]) {
		UISegmentedControlProxy *but = (UISegmentedControlProxy *)self;
		NSMutableString* label = [[NSMutableString alloc] init];
		int i;
		for (i = 0; i < [but numberOfSegments]; i++) {
			NSString* title = [but titleForSegmentAtIndex:i];
			if (title == nil) {
				goto use_default;
			}
			[label appendString:title];
		}
		return label;
	}

	
use_default:;

    NSArray* rawCandidates = [self rawUTesterIDCandidates];
    for (int rawNdx=0; rawNdx<rawCandidates.count; rawNdx++) {
        NSString* candidate=rawCandidates[rawNdx];
        if (candidate !=nil && candidate.length>0) {
            return candidate;
        }
    }
    
    return [[UTestTools sharedUTester] uTesterIDfor:self];
}

- (NSInteger) uttOrdinal {
    if ([self hasUTesterIdAssigned]) {
        NSDictionary *uTesterDict = [[UTestTools sharedUTester].componentUTesterIds objectForKey:[self keyForUTesterId]];
        NSInteger ordinal = [[uTesterDict objectForKey:@"ordinal"] integerValue];
        
        return ordinal;
    }
    
    return [UTTOrdinalView componentOrdinalForView:self withUTesterID:nil];
}

- (BOOL) swapsWith:(NSString*)className {
	if ([self isKindOfClass:objc_getClass("UIToolbarTextButton")] && [className isEqualToString:@"UINavigationButton"]) {
		return YES;
	}
	
	if ([self isKindOfClass:objc_getClass("UINavigationButton")] && [className isEqualToString:@"UIToolbarTextButton"]) {
		return YES;
	}
	
	return NO;
	
}




- (void) uttAddGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
        
    [self uttAddGestureRecognizer:gestureRecognizer];
}

@end