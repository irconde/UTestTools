/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIScrollView+UTTReady.h"
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import "UITableView+UTTReady.h"
#import "NSString+UTestTools.h"
#import "NSObject+UTTReady.h"

@interface UIScrollView (UTT_INTERCEPTOR)
-(void) orig_scrollViewDidScroll:(UIScrollView *) scrollView;
-(void) orig_scrollViewWillBeginDragging:(UIScrollView *) scrollView;
-(void) orig_scrollViewDidEndDecelerating:(UIScrollView *) scrollView;
-(void) orig_scrollViewDidEndScrollingAnimation:(UIScrollView *) scrollView;
- (void)orig_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@implementation UIScrollView (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentScroller;
}

- (BOOL) isUTTEnabled {
	return YES;
}

+ (void)load {
    if (self == [UIScrollView class]) {
        Method originaMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method replaceMethod = class_getInstanceMethod(self, @selector(uttSetDelegate:));
        method_exchangeImplementations(originaMethod, replaceMethod);
		
    }
}

- (void)uttTriggerRefreshControl {
    UITableViewController *del = self.delegate;
    
    if (del.refreshControl) {
        [del.refreshControl performSelector:@selector(beginRefreshing) withObject:nil afterDelay:0.3];
        [del.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
        
        [del.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
}


-(void) uttSetDelegate:(NSObject <UIScrollViewDelegate> *)del {
    [del interceptMethod:@selector(scrollViewDidScroll:) withClass:[self class] types:"c@:@"];
    [del interceptMethod:@selector(scrollViewWillBeginDragging:) withClass:[self class] types:"c@:@"];
    [del interceptMethod:@selector(scrollViewDidEndDecelerating:) withClass:[self class] types:"c@:@"];
    [del interceptMethod:@selector(scrollViewDidEndScrollingAnimation:) withClass:[self class] types:"c@:@"];
    [del interceptMethod:@selector(scrollViewDidEndDragging:willDecelerate:) withClass:[self class] types:"c@:@"];
    
    [self uttSetDelegate:del];
}

- (void)recordTableScrollToRow {
    UITableView* table = (UITableView*) self;
    NSArray* cells = [table visibleCells];
    
    // Handle pull to refresh behavior by recording scroll on table view
    // if the y offset is negative, otherwise record scroll to row
    if (self.contentOffset.y >= 0) {
        if ([cells count]) {
            UITableViewCell *topCell = (UITableViewCell *)[cells objectAtIndex:0];
            NSIndexPath* indexPath = [table indexPathForCell:topCell];
            NSArray *recordArray = [NSArray
                                    arrayWithObjects:
                                    [NSString stringWithFormat:@"%d", indexPath.row+1],
                                    indexPath.section == 0 ? nil : [NSString stringWithFormat:@"%d", indexPath.section], nil];
            
            // Record index path and not text label for now
            //                if ([topCell.textLabel.text length] > 0)
            //                    recordArray = [NSArray arrayWithObject:topCell.textLabel.text];
            //                else
            //                    recordArray = [NSArray
            //                                   arrayWithObjects:
            //                                   [NSString stringWithFormat:@"%d", indexPath.row+1],
            //                                   indexPath.section == 0 ? nil : [NSString stringWithFormat:@"%d", indexPath.section], nil];
            
            // Record table view scroll to row
            [[UTestTools sharedUTester] postCommandFrom:self
                                               command:UTTCommandScrollToRow
                                                  args:recordArray];
        }
    }
}

- (void)recordScroll {
    // Do not record scroll on UIPickerTableView and _UIWebViewScrollView
    if ([self isKindOfClass:objc_getClass("UIPickerTableView")] ||
        [self.superview isKindOfClass:objc_getClass("_UIWebViewScrollView")]) {
        return;
    }
    
    // Since it's unclear exactly how to do this in a subclass (override a swapped method), we do it here instead (sorry)
	if ([self isKindOfClass:[UITableView class]] && self.contentOffset.y >= 0) {
		[self recordTableScrollToRow];
	} else {
        CGPoint offsetEndPoint;
        offsetEndPoint.x = self.contentOffset.x;
        offsetEndPoint.y = self.contentOffset.y;
        
        [UTestTools recordEvent:[UTTCommandEvent command:UTTCommandScroll
                                              className:[NSString stringWithUTF8String:class_getName([self class])]
                                               uTesterID:self.uTesterID
                                                   args:[NSArray arrayWithObjects:
                                                         [NSString stringWithFormat:@"%1.0f",(float)offsetEndPoint.x],
                                                         [NSString stringWithFormat:@"%1.0f", (float)offsetEndPoint.y], nil]]];
    }
}

#pragma ScrollView Delegates

-(void) utt_scrollViewDidSroll:(UIScrollView *) scrollView {
    if ([self respondsToSelector:@selector(orig_scrollViewDidScroll:)])
        [self orig_scrollViewDidScroll:scrollView];
}

-(void) utt_scrollViewWillBeginDragging:(UIScrollView *) scrollView {
    if ([self respondsToSelector:@selector(orig_scrollViewWillBeginDragging:)])
        [self orig_scrollViewWillBeginDragging:scrollView];
}

-(void) utt_scrollViewDidEndDecelerating:(UIScrollView *) scrollView {
    // record content offset at the end of deceleration
    [scrollView recordScroll];
    
    if ([self respondsToSelector:@selector(orig_scrollViewDidEndDecelerating:)])
        [self orig_scrollViewDidEndDecelerating:scrollView];
}

- (void)utt_scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // record content offset at end of drag
        [scrollView recordScroll];
    } else if ([scrollView isKindOfClass:[UITableView class]] && scrollView.contentOffset.y < 0) {
        [scrollView recordScroll];
    }
    
    if ([self respondsToSelector:@selector(orig_scrollViewDidEndDragging:willDecelerate:)])
        [self orig_scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

-(void) utt_scrollViewDidEndScrollingAnimation:(UIScrollView *) scrollView {
    if ([self respondsToSelector:@selector(orig_scrollViewDidEndScrollingAnimation:)])
        [self orig_scrollViewDidEndScrollingAnimation:scrollView];
}

- (BOOL) shouldRecordUTester:(UITouch*)touch {
	return NO;
}

@end
