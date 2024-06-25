/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <objc/runtime.h>
#import "UITableView+UTTReady.h"
#import "UTTCommandEvent.h"
#import "UTestTools.h"
#import "UIView+UTTReady.h"
#import "NSObject+UTTReady.h"
#import "NSString+UTestTools.h"
#import "UIGestureRecognizer+UTTReady.h"


@interface UITableView (Intercept)
- (void)originalTableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
- (void)origTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) originalTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation UITableView (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentTable;
}

+ (void)load {
    if (self == [UITableView class]) {
		
        Method originalMethod = class_getInstanceMethod(self, @selector(setDataSource:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttSetDataSource:));
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}



- (void) uttSetDataSource:(NSObject <UITableViewDataSource>*) del {
	
	if ([del uttHasMethod:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
		[del  interceptMethod:@selector(tableView:commitEditingStyle:forRowAtIndexPath:) 
				   withMethod:@selector(uttTableView:commitEditingStyle:forRowAtIndexPath:) 
					  ofClass:[self class] 
				   renameOrig:@selector(origTableView:commitEditingStyle:forRowAtIndexPath:) 
						types:"v@:@i@"];
        
        [del  interceptMethod:@selector(tableView:didSelectRowAtIndexPath:) 
				   withMethod:@selector(uttTableView:didSelectRowAtIndexPath:) 
					  ofClass:[self class] 
				   renameOrig:@selector(originalTableView:didSelectRowAtIndexPath:) 
						types:"v@:@i@"];
        
        [del  interceptMethod:@selector(tableView:moveRowAtIndexPath:toIndexPath:) 
				   withMethod:@selector(uttTableView:moveRowAtIndexPath:toIndexPath:) 
					  ofClass:[self class] 
				   renameOrig:@selector(originalTableView:moveRowAtIndexPath:toIndexPath:) 
						types:"v@:@i@"];
        
        [del  interceptMethod:@selector(insertRowsAtIndexPaths:withRowAnimation:) 
				   withMethod:@selector(uttInsertRowsAtIndexPaths:withRowAnimation:) 
					  ofClass:[self class] 
				   renameOrig:@selector(originalInsertRowsAtIndexPaths:withRowAnimation:) 
						types:"v@:@i@"];
        
	}
	[self uttSetDataSource:del];
}


- (void)uttTableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    if (sourceIndexPath != destinationIndexPath)
        [UTestTools recordFrom:tableView command:UTTCommandMove args:[NSArray arrayWithObjects: [NSString stringWithFormat: @"%d", sourceIndexPath.row+1], [NSString stringWithFormat:@"%d", destinationIndexPath.row+1], nil]];
    
    [self originalTableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

- (void)uttTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[UTestTools recordFrom:tableView command:UTTCommandRemove args:[NSArray arrayWithObjects: [NSString stringWithFormat: @"%d", indexPath.row+1], [NSString stringWithFormat:@"%d", indexPath.section+1], nil]];
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [UTestTools recordFrom:tableView command:UTTCommandInsert args:[NSArray arrayWithObjects: [NSString stringWithFormat: @"%d", indexPath.row+1], [NSString stringWithFormat:@"%d", indexPath.section+1], nil]];
    }
	[self origTableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}


+ (NSIndexPath *) indexPathForCellTextLabel:(UITableView *)tableView withTitle:(NSString *)title {
    NSIndexPath *indexPath = nil;
    for (int i = 0; i < [tableView numberOfSections]; i++) {
        for (int j = 0; j < [tableView numberOfRowsInSection:i]; j++) {
            NSIndexPath *currentPath = [NSIndexPath indexPathForRow:j inSection:i];
            UITableViewCell *cell = nil;
            
            if ([tableView.dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)] &&
                ![tableView.dataSource isKindOfClass:NSClassFromString(@"UIMoreListController")])
                cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:currentPath];
            else
                cell = [tableView cellForRowAtIndexPath:currentPath];
            
            if (!cell)
                continue;
            
            if ([cell.textLabel.text isEqualToString:title]) {
                indexPath = currentPath;
                break;
            }
        }
        
        if (indexPath != nil)
            break;
    }
    return indexPath;
}

- (void) uttTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *section = [NSString stringWithFormat:@"%i",indexPath.section+1];
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row+1];
    NSMutableArray *argsArray = [[NSMutableArray alloc] initWithObjects:row, nil];
    
    if (indexPath.section > 0)
        [argsArray addObject:section];
    
    [UTestTools recordFrom:tableView
                   command:UTTCommandSelectIndex
                      args:argsArray];
    
    if ([self respondsToSelector:@selector(originalTableView:didSelectRowAtIndexPath:)]) {
        [self originalTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
