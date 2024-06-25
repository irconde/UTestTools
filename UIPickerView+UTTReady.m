/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIPIckerView+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "NSString+UTestTools.h"
#import "UIView+UTTReady.h"

@interface UIPickerView (Intercept)
- (void)origPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
@end

@implementation UIPickerView (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentSelector;
}

+ (void)load {
    if (self == [UIPickerView class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttSetDelegate:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}


- (void) uttSetDelegate:(id <UIPickerViewDelegate>) del {
	Method originalMethod = class_getInstanceMethod([del class], @selector(pickerView:didSelectRow:inComponent:));
	if (originalMethod) {
		IMP origImp = method_getImplementation(originalMethod);
		Method replacedMethod = class_getInstanceMethod([self class], @selector(uttPickerView:didSelectRow:inComponent:));
		IMP replImp = method_getImplementation(replacedMethod);
		
		if (origImp != replImp) {
			method_setImplementation(originalMethod, replImp);
			class_addMethod([del class], @selector(origPickerView:didSelectRow:inComponent:), origImp,"v@:@ii");
		}
	}
	[self uttSetDelegate:del];

}

- (void)uttPickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *rowString = [NSString stringWithFormat:@"%i",row+1];
    NSString *componentString = [NSString stringWithFormat:@"%i",component+1];
    
    NSString *selectedTitle = @"";
    
    if (![self isKindOfClass:objc_getClass("_UIDatePickerView")] && ![self isKindOfClass:objc_getClass("UIDatePickerView")]) {

        if ([self respondsToSelector:@selector(pickerView:titleForRow:forComponent:)])
        {
            selectedTitle = [self pickerView:self titleForRow:row forComponent:component];
        }
        
        NSMutableArray *argsArray = [[NSMutableArray alloc] initWithObjects:rowString, nil];
        
        if ([componentString intValue] > 1)
            [argsArray addObject:componentString];
        
        if ([selectedTitle length] > 0)
            [ UTestTools recordEvent:[[UTTCommandEvent alloc]
                                      init:UTTCommandSelect className:@"UIPickerView" uTesterID:[pickerView uTesterID] args:[NSArray arrayWithObject:selectedTitle]]];
        else
            [ UTestTools recordEvent:[[UTTCommandEvent alloc]
                                      init:UTTCommandSelectIndex className:@"UIPickerView" uTesterID:[pickerView uTesterID] args:argsArray]];
        
    }
    
	[self origPickerView:pickerView didSelectRow:row inComponent:component];
}	


- (BOOL) shouldRecordUTester:(UITouch*)touch {
	return NO;
}


@end
