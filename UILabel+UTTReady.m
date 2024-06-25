/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UILabel+UTTReady.h"
#import "UIView+UTTReady.h"
#import "UTTOrdinalView.h"

#import <UIKit/UIEvent.h>


@implementation UILabel (UTTReady)

- (NSString *)uttComponent {
    return UTTComponentLabel;
}

- (NSString *)uttDefaultValueKeyPath {
    return @"text";
}

- (NSString *) baseUTesterID {
    if (self.text && self.text.length>0) {
        return self.text;
    }
    return [super baseUTesterID];
}

@end
