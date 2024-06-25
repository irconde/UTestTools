/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UISegmentedControl+UTTReady.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UTTUtils.h"
#import "UISegmentedControlProxy.h"
#import "NSString+UTestTools.h"
#import "UIView+UTTReady.h"
#import <objc/runtime.h>
#import "UTTUtils.h"
#import "NSObject+UTTReady.h"

@interface UISegmentedControl (UTTDummy)
- (NSString *)infoName;
@end

@implementation UISegmentedControl (UTTReady)
- (NSString *)uttComponent {
    return UTTComponentButtonSelector;
}

+ (void)load {
    if (self == [UISegmentedControl class]) {
        [NSObject swizzle:@"initWithItems:" with:@"uttinitWithItems:" for:self];
        [NSObject swizzle:@"initWithFrame:" with:@"uttinitWithFrame:" for:self];
        [NSObject swizzle:@"initWithCoder:" with:@"uttinitWithCoder:" for:self];
    }
}

- (id)uttinitWithItems:(NSArray *)items {
    [self uttinitWithItems:items];
    
    if (self) {
        [self addTarget:self action:@selector(uttSegmentedControlDidChange) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (id)uttinitWithFrame:(CGRect)frame {
    [self uttinitWithFrame:frame];
    
    if (self) {
        [self addTarget:self action:@selector(uttSegmentedControlDidChange) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}

- (id)uttinitWithCoder:(NSCoder *)aDecoder {
    [self uttinitWithCoder:aDecoder];
    
    if (self) {
        [self addTarget:self action:@selector(uttSegmentedControlDidChange) forControlEvents:UIControlEventValueChanged];
    }
    
    return self;
}


- (void)uttSegmentedControlDidChange {
    UISegmentedControlProxy *tmp = (UISegmentedControlProxy *)self;
    int index = tmp.selectedSegmentIndex;
    if (index < 0) {
        return;
    }
    NSString* title = [tmp titleForSegmentAtIndex:index];
    NSString* command = UTTCommandSelect;
    
    if (title == nil) {
        title = [NSString stringWithFormat:@"%d", index+1];
        command = UTTCommandSelectIndex;
    }
    
    [UTestTools recordFrom:self command:command args:[NSArray arrayWithObject:title]];
}

- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
    // moved recording to uttSegmentedControlDidChange
}
@end
