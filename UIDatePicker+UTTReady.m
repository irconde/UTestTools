/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIDatePicker+UTTReady.h"
#import "UTTCommandEvent.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "UTestTools.h"
#import "NSString+UTestTools.h"
#import "UIView+UTTReady.h"

@implementation UIDatePicker (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentDatePicker;
}


+ (void)load {
    if (self == [UIDatePicker class]) {
        
        Method originalInitFrame = class_getInstanceMethod(self, @selector(initWithFrame:));
        Method replacedInitFrame = class_getInstanceMethod(self, @selector(uttinitWithFrame:));
        Method originalInitCoder = class_getInstanceMethod(self, @selector(initWithCoder:));
        Method replacedInitCoder = class_getInstanceMethod(self, @selector(uttinitWithCoder:));
        
        method_exchangeImplementations(originalInitFrame, replacedInitFrame);
        method_exchangeImplementations(originalInitCoder, replacedInitCoder);
    }
}


- (void) uttDateChanged {
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    if (self.datePickerMode == UIDatePickerModeDate)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [UTestTools recordEvent:[[UTTCommandEvent alloc] init:UTTCommandEnterDate
                                                   className: [NSString stringWithUTF8String:class_getName(self.class)]
                                                    uTesterID:[self uTesterID]
                                                        args:[NSArray arrayWithObject:[dateFormatter stringFromDate:self.date]]]];
    }

    else if(self.datePickerMode == UIDatePickerModeDateAndTime)
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        [UTestTools recordEvent:[[UTTCommandEvent alloc] init:UTTCommandEnterDateAndTime
                                                   className:[NSString stringWithUTF8String:class_getName(self.class)]
                                                    uTesterID:[self uTesterID]
                                                        args:[NSArray arrayWithObject:[dateFormatter stringFromDate:self.date]]]];
    }
    else if(self.datePickerMode == UIDatePickerModeTime)
    {
        [dateFormatter setDateFormat:@"hh:mm a"];
        [UTestTools recordEvent:[[UTTCommandEvent alloc] init:UTTCommandEnterTime
                                                   className:[NSString stringWithUTF8String:class_getName(self.class)]
                                                    uTesterID:[self uTesterID]
                                                        args:[NSArray arrayWithObject:[dateFormatter stringFromDate:self.date]]]];

        
    }
    else if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
        [dateFormatter setDateFormat:@"HH:mm"];

        [UTestTools recordEvent:[[UTTCommandEvent alloc] init:UTTCommandEnterCountDownTimer
                                                   className:[NSString stringWithUTF8String:class_getName(self.class)]
                                                    uTesterID:[self uTesterID]
                                                        args:[NSArray arrayWithObject:[dateFormatter stringFromDate:self.date]]]];
    }
    
}

- (void) uttsetDate:(NSDate *)date animated:(BOOL)animated {
    [self uttsetDate:date animated:animated];
}

- (id) uttinitWithFrame:(CGRect)frame {
    [self uttinitWithFrame:frame];
    [self addTarget:self action:@selector(uttDateChanged) forControlEvents:UIControlEventValueChanged];
    return self;
}

- (id) uttinitWithCoder:(NSCoder *)aDecoder {
    [self uttinitWithCoder:aDecoder];
    [self addTarget:self action:@selector(uttDateChanged) forControlEvents:UIControlEventValueChanged];
    return self;
}

@end
