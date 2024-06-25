/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UITableViewCell+UTTReady.h"
#import <objc/runtime.h>
#import "UIView+UTTReady.h"
#import "UTTUtils.h"
#import "UTestTools.h"
#import "UTTCommandEvent.h"

@implementation UITableViewCell (UTTReady)


- (BOOL) isUTTEnabled {
	return YES;
}

- (UITableView *)parentTable {
    UITableView *tableView = (UITableView *)self.superview;
    
    while (![tableView isKindOfClass:[UITableView class]]) {
        if (!tableView.superview) {
            return nil;
        }
        tableView = (UITableView *)tableView.superview;
    }
    return tableView;;
}


- (void) handleUTesterTouchEvent:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch* touch = [touches anyObject];
    UITableView *parentTable = [self parentTable];
    
    if (!parentTable) {
        return;
    }

	if (touch) {
		NSString* cname = [UTTUtils className:touch.view];
        
		if (cname) {
			if ([cname isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
				return;
			}
			
			if ([cname isEqualToString:@"UITableViewCellEditControl"]) {
				return;
			}
            
            if ([cname isEqualToString:@"UITableViewCellContentView"]) {
                CGPoint location = [touch locationInView:parentTable];
                NSIndexPath *indexPath = [parentTable indexPathForRowAtPoint:location];
                NSString *section = [NSString stringWithFormat:@"%i",indexPath.section+1];
                NSString *row = [NSString stringWithFormat:@"%i",indexPath.row+1];
                
                // Ignorar los toques en UIPickerTableView
                if ([parentTable isKindOfClass:objc_getClass("UIPickerTableView")])
                    return;
                
                NSMutableArray *argsArray = [[NSMutableArray alloc] initWithObjects:row, nil];
                
                if ([section intValue] > 1)
                    [argsArray addObject:section];
                
                if (touch.phase == UITouchPhaseEnded) {
                    if ([self isKindOfClass:NSClassFromString(@"_UIModalItemTableViewCell")]) {
                        
                        // grabar las celda UIAlertView como Button.tap
                        
                        UTTCommandEvent *commandEvent = [UTTCommandEvent command:UTTCommandTap component:UTTComponentButton className:UTTComponentButton uTesterID:self.textLabel.text args:nil modifiers:nil];
                        [UTestTools recordEvent:commandEvent];
                    } else if ([self.textLabel.text length] > 0) {
                        [UTestTools recordFrom:parentTable
                                       command:UTTCommandSelect
                                         args:[NSArray arrayWithObject:self.textLabel.text]];
                    } else {
                        [UTestTools recordFrom:parentTable 
                               command:UTTCommandSelectIndex
                                  args:argsArray];
                    }
                }
                
				return;
			}
		}
	}
	[super handleUTesterTouchEvent:touches withEvent:event];
					  
					  
}

- (NSString*) baseUTesterID {
	NSString* label =  [[self textLabel] text];
	if (label && label.length>0) {
		return  label;
	}
	
	label =  [[self detailTextLabel] text];
	if (label && label.length>0) {
		return label;
	}
	
	label =[self text];
	if (label && label.length>0) {
		return label;
	}
	
	for (UIView* view in [[self contentView] subviews]) {
        UILabel *l = (UILabel *)view;
		if ([l respondsToSelector:@selector(text)] && [l text] && [[l text] length]>0) {
			return [l text];
		}
	}
	
	return [super baseUTesterID];
}


@end
