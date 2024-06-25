/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTConvertType.h"
#import "UTestTools.h"
#import "UTTUtils.h"
#import "NSString+UTestTools.h"

@interface UTTConvertType()
+ (NSDictionary *) componentsDictionary;
+ (NSDictionary *) recordDictionary;
@end

@implementation UTTConvertType

// Aliasing
+ (NSDictionary *) componentsDictionary {
    NSMutableDictionary *mutableComponents = [[NSMutableDictionary alloc] init];
    
    [mutableComponents setValue:@"UIView" forKey:[UTTComponentView lowercaseString]];
    [mutableComponents setValue:@"UIButton" forKey:[UTTComponentButton lowercaseString]];
    [mutableComponents setValue:@"UITextField" forKey:[UTTComponentInput lowercaseString]];
    [mutableComponents setValue:@"UILabel" forKey:[UTTComponentLabel lowercaseString]];
    [mutableComponents setValue:@"UITextView" forKey:[UTTComponentTextArea lowercaseString]];
    [mutableComponents setValue:@"UITableView" forKey:[UTTComponentTable lowercaseString]];
    [mutableComponents setValue:@"UIPickerView" forKey:[UTTComponentSelector lowercaseString]];
    [mutableComponents setValue:@"UIDatePicker" forKey:[UTTComponentDatePicker lowercaseString]];
    [mutableComponents setValue:@"UISegmentedControl" forKey:[UTTComponentButtonSelector lowercaseString]];
    [mutableComponents setValue:@"UISlider" forKey:[UTTComponentSlider lowercaseString]];
    [mutableComponents setValue:@"UIScrollView" forKey:[UTTComponentScroller lowercaseString]];
    [mutableComponents setValue:@"UITabBar" forKey:[UTTComponentTabBar lowercaseString]];
    [mutableComponents setValue:@"UIToolbar" forKey:[UTTComponentToolBar lowercaseString]];
    [mutableComponents setValue:@"MPMovieView" forKey:[UTTComponentVideoPlayer lowercaseString]];
    [mutableComponents setValue:@"UILabel" forKey:[UTTComponentLink lowercaseString]];
    [mutableComponents setValue:@"UIStepper" forKey:[UTTComponentStepper lowercaseString]];
    [mutableComponents setValue:@"UIWebView" forKey:[UTTComponentBrowser lowercaseString]];
    [mutableComponents setValue:@"UIImageView" forKey:[UTTComponentImage lowercaseString]];
    [mutableComponents setValue:@"UIWebView" forKey:[UTTComponentWeb lowercaseString]];
    

    [mutableComponents setValue:@"UISwitch" forKey:[UTTComponentToggle lowercaseString]];

    
    [mutableComponents setValue:@"UISegmentedControl" forKey:@"radiobuttons"];
    [mutableComponents setValue:@"UISlider" forKey:@"numericselector"];
    [mutableComponents setValue:@"UISlider" forKey:@"ratingbar"];
    [mutableComponents setValue:@"UITabBar" forKey:@"menu"];
    [mutableComponents setValue:@"UISwitch" forKey:@"checkbox"];
    [mutableComponents setValue:@"UISwitch" forKey:[UTTComponentSwitch lowercaseString]];
    
    return mutableComponents;
}

// Mapeado
+ (NSDictionary *) recordDictionary {
    NSMutableDictionary *mutableComponents = [NSMutableDictionary dictionaryWithObject:UTTComponentView forKey:@"UIView"];
    
    [mutableComponents setValue:UTTComponentButton forKey:@"UIButton"];
    [mutableComponents setValue:UTTComponentButton forKey:@"UINavigationItemButtonView"];
    [mutableComponents setValue:UTTComponentButton forKey:@"UINavigationButton"];
    [mutableComponents setValue:UTTComponentButton forKey:@"UIThreePartButton"];
    [mutableComponents setValue:UTTComponentButton forKey:@"UIRoundedRectButton"];
    [mutableComponents setValue:UTTComponentButton forKey:@"UIToolbarTextButton"];
    [mutableComponents setValue:UTTComponentButton forKey:@"UIAlertButton"];
    [mutableComponents setValue:UTTComponentInput forKey:@"UITextField"];
    [mutableComponents setValue:UTTComponentLabel forKey:@"UILabel"];
    [mutableComponents setValue:UTTComponentTextArea forKey:@"UITextView"];
    [mutableComponents setValue:UTTComponentTable forKey:@"UITableView"];
    [mutableComponents setValue:UTTComponentSelector forKey:@"UIPickerView"];
    [mutableComponents setValue:UTTComponentDatePicker forKey:@"UIDatePicker"];
    [mutableComponents setValue:UTTComponentButtonSelector forKey:@"UISegmentedControl"];
    [mutableComponents setValue:UTTComponentSlider forKey:@"UISlider"];
    [mutableComponents setValue:UTTComponentScroller forKey:@"UIScrollView"];
    [mutableComponents setValue:UTTComponentTabBar forKey:@"UITabBar"];
    [mutableComponents setValue:UTTComponentToggle forKey:@"UISwitch"];
    [mutableComponents setValue:UTTComponentToolBar forKey:@"UIToolbar"];
    [mutableComponents setValue:UTTComponentVideoPlayer forKey:@"MPMovieView"];
    [mutableComponents setValue:UTTComponentStepper forKey:@"UIStepper"];
    [mutableComponents setValue:UTTComponentBrowser forKey:@"UIWebView"];
    [mutableComponents setValue:UTTComponentImage forKey:@"UIImageView"];
    [mutableComponents setValue:UTTComponentWeb forKey:@"UIWebView"];
    
    [mutableComponents setValue:UTTComponentToggle forKey:@"_UISwitchInternalView"];
    [mutableComponents setValue:UTTComponentScroller forKey:@"_UIWebViewScrollView"];
      
    return mutableComponents;
}


+ (NSString *) convertedComponentFromString:(NSString *)originalComponent 
                                isRecording:(BOOL)isRecording {
    
    if (isRecording) {
        NSDictionary *recordDictionary = [self recordDictionary];
        if (![recordDictionary objectForKey:originalComponent]) {
            
            NSString *prefix = @"";
            
            if ([originalComponent isEqualToString:UTTComponentDevice ignoreCase:YES])
                prefix = @"";
            
            return [NSString stringWithFormat:@"%@%@",prefix,originalComponent];
        }
        
        return [recordDictionary objectForKey:originalComponent];
    }
    
    if ([[originalComponent substringToIndex:1] isEqualToString:@"." ignoreCase:YES]) {
        
        originalComponent = [originalComponent substringFromIndex:1];
        return originalComponent;
    } else if ([originalComponent isEqualToString:@"Device" ignoreCase:YES])
        return originalComponent;
    
    return [[self componentsDictionary] objectForKey:[originalComponent lowercaseString]];
}

@end
