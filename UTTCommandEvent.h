/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSArray.h>

/**
 Clase usada por UTestTools para grabar comandos a partir de los eventos registrados. Cada objeto de UTTCommandEvent encapsula la informaci&oacute;n relativa a un evento.
 */
@interface UTTCommandEvent : NSObject <NSCopying> {
    
	
    UIView* source;
	NSString* command;
    NSString* component;
	NSString* className;
	NSString* uTesterID;
	NSArray* args;
	NSMutableDictionary* dict;
	NSString* lastResult;
    NSString* value;
    Boolean found;
    Boolean isWebRecording;
    NSDictionary *uTesterOrdinal;
    NSString *timestamp;
}

+ (UTTCommandEvent*) command:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array;
+ (UTTCommandEvent*) command:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array modifiers:(NSDictionary *)theModifiers;
+ (UTTCommandEvent*) command:(NSString*)cmd component:(NSString *)uttComponent className:(NSString*)name uTesterID:(NSString*)mid args:(NSArray*)cmdArgs modifiers:(NSDictionary *)mods;
- (id) init:(NSString*)cmd className:(NSString*)className uTesterID:(NSString*)uTesterID args:(NSArray*)args;
- (id) init:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array modifiers:(NSDictionary *)theModifiers;
- (id) initWithDict:(NSMutableDictionary*)dict;
+ (NSDictionary *) uTesterOrdinalFromId:(NSString *)uTesterId;
- (NSString *)printUTesterId;
- (NSString *)printArgs;
- (NSString *)printCommand;

@property (unsafe_unretained, readonly) UIView* source;
@property (nonatomic, strong) NSString* command;
@property (nonatomic, strong) NSString* component;
@property (nonatomic, strong) NSString* className;
@property (nonatomic, strong) NSString* uTesterID;
@property (nonatomic, strong) NSString* lastResult;
@property (nonatomic, strong) NSArray* args;
@property (nonatomic, strong) NSMutableDictionary* dict;
@property (nonatomic, strong) NSMutableDictionary* modifiers;
@property (nonatomic, strong) NSString* value;
@property (nonatomic, readwrite) Boolean found;
@property (nonatomic, readwrite) Boolean isWebRecording;
@property (nonatomic, strong) NSDictionary *uTesterOrdinal;
@property (nonatomic, readonly) BOOL skipWebView;
@property (nonatomic, strong) NSString *timestamp;

@end
