/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTCommandEvent.h"
#import "UTTUtils.h"
#import "UTTOrdinalView.h"
#import "UTTConvertType.h"
#import "UIView+UTTReady.h"
#import "UIView+UTTFinder.h"

@implementation UTTCommandEvent

@synthesize dict, found, uTesterOrdinal, isWebRecording, command;

- (id) init {
	if (self = [super init]) {
		dict = [[NSMutableDictionary alloc] initWithCapacity:6];
		[self setCommand:@"Verify"];
		[self setUTesterID:@""];
		[self setClassName:@""];
		[self setArgs:[NSMutableArray arrayWithCapacity:1]];
        [self setModifiers:[NSMutableDictionary dictionaryWithCapacity:1]];
        [self setTimestamp:[UTTUtils timeStamp]];
	}
	
	return self;
}


- (id) init:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array {
	self = [self init];
	self.command = cmd;
	self.className = name;
	self.uTesterID = id;
	self.args = array;
    [self setTimestamp:[UTTUtils timeStamp]];
	return self;
}

- (id) init:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array modifiers:(NSDictionary *)theModifiers {
	self = [self init];
    
	self.command = cmd;
	self.className = name;
	self.uTesterID = id;
    self.value = nil;
    self.found = NO;
    self.isWebRecording = NO;
    
	self.args = array;
    self.modifiers = theModifiers;
    [self setTimestamp:[UTTUtils timeStamp]];
    
	return self;
}

- (id) init:(NSString*)cmd component:(NSString *)uttComponent className:(NSString*)name uTesterID:(NSString*)mid args:(NSArray*)cmdArgs modifiers:(NSDictionary *)mods {
	self = [self init:cmd className:name uTesterID:mid args:cmdArgs modifiers:mods];
	self.component = uttComponent;
	return self;
}

+ (UTTCommandEvent*) command:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array {
	return [[UTTCommandEvent alloc] init:cmd className:name uTesterID:id args:array];
}

+ (UTTCommandEvent*) command:(NSString*)cmd className:(NSString*)name uTesterID:(NSString*)id args:(NSArray*)array modifiers:(NSDictionary *)theModifiers {
	return [[UTTCommandEvent alloc] init:cmd className:name uTesterID:id args:array modifiers:theModifiers];
}

+ (UTTCommandEvent*) command:(NSString*)cmd component:(NSString *)uttComponent className:(NSString*)name uTesterID:(NSString*)mid args:(NSArray*)cmdArgs modifiers:(NSDictionary *)mods {
	return [[UTTCommandEvent alloc] init:cmd component:uttComponent className:name uTesterID:mid args:cmdArgs modifiers:mods];
}

// protocolo NSCopying
- (id) copyWithZone:(NSZone*)zone {
	return [UTTCommandEvent command:self.command component:self.component className:self.className uTesterID:self.uTesterID args:self.args modifiers:self.modifiers];
}

- (id) initWithDict:(NSMutableDictionary*)dictionary {
	if (self = [super init]) {
		self.dict = dictionary;
	}

	return self;
}

- (UIView*) source {
    NSString *sourceClass = self.className;
    NSString *sourceId = self.uTesterID;
    
	UIView* v = [UIView findViewFromEvent:self];
	if (v) {
		return v;
	}
	return nil;
}

- (void) set:(NSString*)key value:(NSObject*)value {
	if (value == nil) {
		[dict removeObjectForKey:key];
		return;
	}
	[dict setObject:value forKey:key];
}

- (NSString*) command {
	return [dict objectForKey:@"command"];
}

- (void) setCommand:(NSString*)value {
	[self set:@"command" value:value];
}

- (NSString*) uTesterID {
	return [dict objectForKey:@"uTesterID"];

}
- (void) setUTesterID:(NSString*)value {
	[self set:@"uTesterID" value:value];
}


- (NSString*) component {
	return [dict objectForKey:@"component"];
}

- (void) setComponent:(NSString*)value {
	[self set:@"component" value:value];
}

- (NSString*) className {
	return [dict objectForKey:@"className"];
}

- (void) setClassName:(NSString*)value {
	[self set:@"className" value:value];
}

- (NSArray*) args {
	return [dict objectForKey:@"args"];
}
	
- (void) setArgs:(NSArray*)value {
	[self set:@"args" value:value];
}

- (NSDictionary*) modifiers {
	return [dict objectForKey:@"modifiers"];
}

- (void) setModifiers:(NSDictionary *)value {
	[self set:@"modifiers" value:value];
}

- (NSString*) lastResult {
	return [dict objectForKey:@"lastResult"];
}

- (void) setLastResult:(NSString*)value {
	[self set:@"lastResult" value:value];
}


- (NSString*) value {
	return [dict objectForKey:@"value"];
}

- (void) setValue:(NSString*)value {
	[self set:@"value" value:value];
}


- (NSDictionary *) uTesterOrdinal {
    if (!uTesterOrdinal) {
        uTesterOrdinal = [[self class] uTesterOrdinalFromId:self.uTesterID];
    }
    
    return uTesterOrdinal;
}

+ (NSDictionary *) uTesterOrdinalFromId:(NSString *)uTesterId {
    NSDictionary *uTesterOrdinal = nil;
    NSString* regexString = @"\\(\\d+\\)$";
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc]
                                  initWithPattern:regexString
                                  options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"RegEx error.");
    }
    
    NSArray* regexResults = [regex matchesInString:uTesterId options:0
                                             range:NSMakeRange(0, [uTesterId length])];
    
    NSString* foundRegex = nil;
    
    for (NSTextCheckingResult* b in regexResults)
    {
        foundRegex = [uTesterId substringWithRange:b.range];
    }
    
    if (foundRegex) {
        NSString *mid = [uTesterId stringByReplacingOccurrencesOfString:foundRegex withString:@""];
        NSString *ordinal = [foundRegex stringByReplacingOccurrencesOfString:@"(" withString:@""];
        ordinal = [ordinal stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray *objects = [NSArray arrayWithObjects:mid,ordinal, nil];
        NSArray *keys = [NSArray arrayWithObjects:@"mid",@"ordinal", nil];
        uTesterOrdinal = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    
    return uTesterOrdinal;
}

- (NSString *)printUTesterId {
    if ([self.uTesterID rangeOfString:@" "].location == NSNotFound) {
        return self.uTesterID;
    } else {
        return [NSString stringWithFormat:@"\"%@\"", self.uTesterID];
    }
}

- (NSString *)printArgs {
    NSString *s = @"";
    
    for (NSString *arg in self.args) {
        if ([arg rangeOfString:@" "].location == NSNotFound) {
            s = [s stringByAppendingFormat:@" %@", arg];
        } else {
            s = [s stringByAppendingFormat:@" \"%@\"", arg];
        }
    }
    return s;
}


- (NSString *)printCommand {
    return [NSString stringWithFormat:@"%@ %@ %@%@%@",
            self.className,
            self.printUTesterId,
            self.command,
            self.printArgs];
}


@end
