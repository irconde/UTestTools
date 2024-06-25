/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>

#define UTTComponentApp @"App"
#define UTTComponentView @"View"
#define UTTComponentButton @"Button"
#define UTTComponentInput @"Input"
#define UTTComponentTextArea @"TextArea"
#define UTTComponentLabel @"Label"
#define UTTComponentTable @"Table"
#define UTTComponentSelector @"ItemSelector"
#define UTTComponentDatePicker @"DatePicker"
#define UTTComponentButtonSelector @"ButtonSelector"
#define UTTComponentRadioButtons @"RadioButtons"
#define UTTComponentSlider @"Slider"
#define UTTComponentScroller @"Scroller"
#define UTTComponentTabBar @"TabBar"
#define UTTComponentToggle @"Toggle"
#define UTTComponentCheckBox @"CheckBox"
#define UTTComponentToolBar @"ToolBar"
#define UTTComponentVideoPlayer @"VideoPlayer"
#define UTTComponentDevice @"Device"
#define UTTComponentLink @"Link"
#define UTTComponentHTMLTag @"HTMLTag"
#define UTTComponentStepper @"Stepper"
#define UTTComponentBrowser @"Browser"
#define UTTComponentSwitch @"Switch"
#define UTTComponentImage @"Image"
#define UTTComponentWeb @"Web"

#define UTTComponentLib @"UTestTools"
#define UTTComponentDevice @"Device"
#define UTTComponentOS @"OS"

/**
 Clase usada para asigna
 */
@interface UTTConvertType : NSObject {
    
}

+ (NSString *) convertedComponentFromString:(NSString *)originalComponent 
                                isRecording:(BOOL)isRecording;

@end
