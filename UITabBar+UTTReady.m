/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UITabBar+UTTReady.h"
#import "UTestTools.h"
#import "UIView+UTTReady.h"
#import "NSString+UTestTools.h"

@implementation UITabBar (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentTabBar;
}


- (void) handleTabBar:(UITabBar *)tabBar {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Pequeño retardo para obtener la pestaña a la que se navega
        
        [NSThread sleepForTimeInterval:0.1];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UITabBarController *tbController = (UITabBarController *)tabBar.delegate;
            
            NSString *uTesterID = tabBar.selectedItem.title;
            NSString *command = @"";
            
            if ([uTesterID length] == 0) {
                
                NSUInteger selected = 0;
                
                for (UITabBarItem *item in tabBar.items) {
                    if (item == tabBar.selectedItem)
                        break;
                    selected++;
                }
                
               
                NSUInteger selectedIndex = 0;
                
                if ([tbController respondsToSelector:@selector(selectedIndex)]) {
                    selectedIndex = tbController.selectedIndex;
                } else {
                    for (UITabBarItem *item in tabBar.items) {
                        if (item == tabBar.selectedItem)
                            break;
                        selectedIndex++;
                    }
                }
                
                if(selectedIndex == NSNotFound)
                {
                    if([tbController.selectedViewController isEqual:tbController.moreNavigationController] ) {
                        uTesterID = @"More";
                        command = UTTCommandSelect;
                    }
                }
                else {
                    uTesterID = [NSString stringWithFormat:@"%i",selectedIndex+1];
                }
                
                if ([command length] == 0)
                    command = UTTCommandSelectIndex;
            } else {
                command = UTTCommandSelect;
            }
            
            NSArray *uTesterArg = [NSArray arrayWithObject:uTesterID];
            
            [UTestTools recordFrom:tabBar command:command args:uTesterArg];
        }); 
    });
}


-(CGPoint) locationOfTabItemInTabBar:(UITabBar *)tabBar withIndex:(NSInteger) index {
    
    NSUInteger currentIndex = 0;
    
    for (UIView *subView in tabBar.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (currentIndex == index) {
                return subView.frame.origin;
            }
            else
                currentIndex++;
        }
    }
    NSAssert(NO, @"Index out of Bounds");
    return CGPointZero;
}

@end
