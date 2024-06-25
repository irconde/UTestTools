/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <unistd.h>
#import <Foundation/Foundation.h>
#import "UTestTools.h"
#import "UTTCommandEvent.h"
#import "UIView+UTTReady.h"
#import <UIKit/UIView.h>
#import "UTTUtils.h"
#import <objc/runtime.h>
#import "UTTCommandEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "UTTWireSender.h"
#import "UTTConvertType.h"
#import "UTTRotateCommand.h"
#import "NSString+UTestTools.h"
#import "UIApplication+UTTReady.h"
#import "UTTOrdinalView.h"


@implementation UTestTools
static UTestTools* _sharedUTester = nil;

UTTCommandEvent* lastCommandPosted;
BOOL _lastCommandRecorded = YES;

@synthesize commandQueue, commandList, commands,commandSpeed, isWireRecording,foundComponents, uTesterComponents, currentOrientation, componentUTesterIds, currentTapCommand;

NSMutableDictionary* _uTesterIDs;


+(UTestTools*)sharedUTester
{
	@synchronized([UTestTools class])
	{
		if (!_sharedUTester) {

			[[self alloc] init];
			
			_uTesterIDs = [[NSMutableDictionary alloc] init];
            

		}
		return _sharedUTester;
	}
	
	return nil;
}


+(id)alloc
{
	@synchronized([UTestTools class])
	{
		NSAssert(_sharedUTester == nil, @"Intento de creación de una nueva instancia de la librería");
		_sharedUTester = [super alloc];
		return _sharedUTester;
	}
	
	return nil;
}


-(void) receivedRotate: (NSNotification*) notification
{
	UIWindow* _appWindow;
	UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	
	if ((interfaceOrientation = UIDeviceOrientationLandscapeLeft) ||
		(interfaceOrientation = UIDeviceOrientationLandscapeRight)) {

		CGAffineTransform transform = CGAffineTransformMakeRotation(-3.14159/2);
		
		_appWindow = [UTTUtils rootWindow];
		
		
		CGRect contentRect = [_appWindow bounds];
		if (contentRect.size.height > contentRect.size.width) {
			CGFloat temp = contentRect.size.height;
			contentRect.size.height = contentRect.size.width;
			contentRect.size.width = temp;
		}

		
	} else {
		CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	
		_appWindow = [UTTUtils rootWindow];
		
		
		CGRect contentRect = [_appWindow bounds];
		if (contentRect.size.height < contentRect.size.width) {
			CGFloat temp = contentRect.size.height;
			contentRect.size.height = contentRect.size.width;
			contentRect.size.width = temp;
		}
		
	}
	
}



+ (void) sendRecordEvent:(UTTCommandEvent *)event {
    [UTTWireSender sendRecordEvent:event];
}

- (void) recordEvent:(UTTCommandEvent*)event {
    UIView *view = event.source;
    [self recordEvent:event withSource:view];
}

- (void) recordEvent:(UTTCommandEvent*)event withSource:(UIView *)view {
	
    if (!isWireRecording) {
		return;
	}
    
    if (!event.isWebRecording && (!view ||
                                  [view isKindOfClass:objc_getClass("UITextEffectsWindow")] ||
                                  [view isKindOfClass:objc_getClass("UITextEffectsWindow")])) {
        return;
    }
	
    if (![view isKindOfClass:objc_getClass("UITabBarButton")]) {
        NSArray* candidates=[view rawUTesterIDCandidates];
        for (int cndx=0; cndx<candidates.count; cndx++) {
            NSString* candidate = candidates[cndx];
            if (candidate!=nil && [candidate length]>0) {
                event.uTesterID = candidate;
                break;
            }
        }
    }
    
    NSInteger ordinal = [UTTOrdinalView componentOrdinalForView:view withUTesterID:view.baseUTesterID];
    if ([self shouldAppendOrdinal:ordinal ToUTesterID:event.uTesterID]) {
        event.uTesterID = [event.uTesterID stringByAppendingFormat:@"(%i)",ordinal];
    }
    
    if ([event.command isEqualToString:UTTCommandShake] ||
        [event.command isEqualToString:UTTCommandRotate]) {
        event.className = UTTComponentDevice;
    }
    

    NSString *recordString = [NSString stringWithFormat:@"\n\n< < < REGISTRANDO EVENTO > > > - fuente:%@\n%@ %@",event.className, [event command], event.uTesterID];
    
    for (NSString *arg in [event args])
        recordString = [recordString stringByAppendingFormat:@" %@\n",[NSString stringWithUTF8String:[arg UTF8String]]];
    
    //Para evitar registrar un comando vacío
    if ([event.command length] >0) {
        if (isWireRecording) {
            NSLog(@"%@\n",recordString);
            [UTTWireSender sendRecordEvent:event];
        }  else {
            [commands addObject:[NSMutableDictionary dictionaryWithDictionary:event.dict]];
        }
    }
}

- (BOOL) shouldAppendOrdinal:(NSInteger)ordinal ToUTesterID:(NSString*)uTesterID {
    NSRegularExpression *regEx =
    [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"(%i)",ordinal] options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger matchCount = [regEx numberOfMatchesInString:uTesterID options:0 range:NSMakeRange(0, [uTesterID length])];
    
    if (ordinal > 1 && [uTesterID rangeOfString:@"#"].location != 0 && matchCount == 0) {
        return TRUE;
    }
    return FALSE;
}

+ (void) buildCommand:(UTTCommandEvent*)event {
    [[self sharedUTester].commands addObject:[NSMutableDictionary dictionaryWithDictionary:event.dict]];
    lastCommandPosted = event;
}


+ (void) recordEvent:(UTTCommandEvent*)event {
	[[self sharedUTester] recordEvent:event];
}

+ (void) recordEvent:(UTTCommandEvent*)event withSource:(UIView *)source {
	[[self sharedUTester] recordEvent:event withSource:source];
}

- (void) recordLastCommand:(NSNotification*) notification {
	[self recordEvent:lastCommandPosted];
	_lastCommandRecorded = YES;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
    
    if (geocoder != nil) {
        
    
    [geocoder reverseGeocodeLocation:locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error){
                           NSLog(@"Geocode ha fallado con el error: %@", error);
                           return;
                           
                       }
                       
                       if(placemarks && placemarks.count > 0)
                           
                       {
                           //do something
                           CLPlacemark *topResult = [placemarks objectAtIndex:0];
                           NSString *addressTxt = [topResult country];
//                           NSLog(@"%@",addressTxt);
                           
//                           NSMutableArray *argsArray = [[NSMutableArray alloc] initWithObjects:addressTxt, nil];
                           
                           // IVAN: Registramos el país desde donde ha sido realizado el test
                           
                           UTTCommandEvent *geoInfo = [[UTTCommandEvent alloc] init:UTTCommandGeolocation className:addressTxt uTesterID:@"*" args:nil];
                           
                           [UTTWireSender sendRecordEvent:geoInfo];
                           
                       }
                   }];
    }
    
    [locationManager stopUpdatingLocation];
}


- (id)init {
	if ((self = [super init])) {
        
        //IVAN
        isWireRecording = YES;
        
		self.commands = [NSMutableArray arrayWithCapacity:12];
				
        lastCommandPosted = [[UTTCommandEvent alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(recordLastCommand:)
													 name:UTTNotificationCommandPosted object:nil];
        
        //IVAN: Ubicación del dispositivo
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
        [locationManager startUpdatingLocation];
        
        geocoder = [[CLGeocoder alloc] init];
        
        
	}
	
	UIDevice* dev = [UIDevice currentDevice];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(recordRotation:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    currentOrientation = [dev orientation];
    
  	
	[dev beginGeneratingDeviceOrientationNotifications];
    

	return self;
}


- (void) recordRotation:(NSNotification *)notification
{
    [UTTRotateCommand recordRotation:notification];
}

-(void)textEditingBegan:(NSNotification *)notification
{
    UIView* view = (UIView *)[notification object];
    view = [UTTUtils findFirstUTesterView:view];
    
    if (view != nil) {
        [view uttAssureAutomationInit];
    }
}



- (void) sendNotification:(NSString*) notificationName object:sender {
	NSNotification *myNotification =
    [NSNotification notificationWithName:notificationName object:sender];
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification:myNotification
	 postingStyle:NSPostWhenIdle
	 coalesceMask:NSNotificationCoalescingOnName
	 forModes:nil];
}


+ (void) recordFrom:(UIView*)source command:(NSString*)command {
	[[self sharedUTester] postCommandFrom:source command:command args:nil];
}

- (BOOL) isGestureCommand:(NSString *)command {
    return ([command isEqualToString:UTTCommandSwipe ignoreCase:YES] ||
            [command isEqualToString:UTTCommandPinch ignoreCase:YES] ||
            [command isEqualToString:UTTCommandLongPress ignoreCase:YES] ||
            [command isEqualToString:UTTCommandRotate ignoreCase:YES] );
}


- (void) recordFrom:(UIView*)source command:(NSString*)command args:(NSArray*)args post:(BOOL)post {
    BOOL isGesture = [self isGestureCommand:command];
    if (![source isUTTEnabled] && !isGesture) {
        return;
    }
    
    
    if (!isWireRecording) {
		return;
	}
    else if (post) {
		[self postCommandFrom:source command:command args:args];
	} else {
		[ UTestTools recordEvent:[[UTTCommandEvent alloc]
								  init:command className:[NSString stringWithUTF8String:class_getName([source class])]
								  uTesterID:[source uTesterID]
								  args:args]];
	}
}
- (void) recordFrom:(UIView*)source command:(NSString*)command uTesterID:(NSString*)uTesterID  args:(NSArray*)args post:(BOOL)post {
    
    if (![source isUTTEnabled])
        return;
    
    
    if (!isWireRecording) {
		return;
	} else if (post) {
		[self postCommandFrom:source command:command args:args];
	} else {
		[ UTestTools recordEvent:[[UTTCommandEvent alloc]
								  init:command className:[NSString stringWithUTF8String:class_getName([source class])]
								  uTesterID:uTesterID
								  args:args]];
	}
}
+ (void) recordFrom:(UIView*)source command:(NSString*)command args:(NSArray*)args {
	[[UTestTools sharedUTester] recordFrom:source command:command args:args post:YES];
}
+ (void) recordFrom:(UIView*)source command:(NSString*)command uTesterID:(NSString *)uTesterID args:(NSArray*)args {
	[[UTestTools sharedUTester] recordFrom:source command:command args:args post:YES];
}
- (void) recordFrom:(UIView*)source command:(NSString*)command  {
    
    if (![source isUTTEnabled])
        return;
    
	[self postCommandFrom:source command:command args:nil];
}


- (void) continueMonitoring {
	if (!isWireRecording) {
		return;
	}
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
}





- (NSString*) lastResult {
	return [self firstErrorIndex] == -1 ? nil : [[self commandAt:[self firstErrorIndex]] lastResult];
}



- (void) clear {
	
    
	[commands removeAllObjects];
}

- (void) handleEvent:(UIEvent*)event {
	
    if (!isWireRecording) {
		return;
	}
	
	BOOL eventHandled = NO;
    
	if (event.type == UIEventTypeTouches) {
		NSSet* touches = [event allTouches];
		UITouch* touch = [touches anyObject];
		//Recuperamos la vista sobre la que se ha hecho Tap
        UIView* view = touch.view;
		view = [UTTUtils findFirstUTesterView:view];
        
		if (view != nil) {
			
            [view uttAssureAutomationInit];
            if ([view shouldRecordUTester:touch]) {
				[view handleUTesterTouchEvent:touches withEvent:event];
				NSLog(@"UTestTools ha recibido un evento\n%@", event);
				eventHandled = YES;
                
			}
		}

	} else if (event.type == UIEventTypeMotion) {
		[[[UIApplication sharedApplication] keyWindow] handleUTesterMotionEvent:event];
		eventHandled = YES;
	}
	else {
		NSLog(@"El evento tiene un tipo inválido");
	}
    
	if (!eventHandled) {
		NSLog(@"Ninguna vista puede gestionar este evento\n%@", event);
		
	}
	[self continueMonitoring];
	return;
    
}

#pragma mark - Playback for Wire Protocol

NSTimeInterval startInterval;
float retryTime;

#pragma mark -



- (IBAction) clear:(id)sender {
	[commands removeAllObjects];
}

- (void)rotate:(UTTCommandEvent*)command {
    
    [UTTRotateCommand rotate:command];
}


- (void) postCommandFrom:(UIView*)sender command:(NSString*)command args:(NSArray*)args {
    BOOL isGesture = [self isGestureCommand:command];
    
    // Added below lines of code to send device orientation recording to IDE
    if (!sender && [command isEqualToString:UTTCommandRotate]) {
        lastCommandPosted.command = command;
        lastCommandPosted.args = args;
        lastCommandPosted.uTesterID = @"#1";
        [self sendNotification:UTTNotificationCommandPosted object:sender];
        return;
    }
    if (![sender isUTTEnabled] && !isGesture)
        return;
    
	if (!isWireRecording) {
		return;
	}
    
    if (!_lastCommandRecorded && lastCommandPosted.uTesterID && lastCommandPosted.uTesterID != [sender uTesterID]) {
        [self recordEvent:lastCommandPosted];
    } else if (([lastCommandPosted.command isEqualToString:UTTCommandDrag] && !_lastCommandRecorded) ||
               [lastCommandPosted.command isEqualToString:UTTCommandTouchUp])
        [self recordEvent:lastCommandPosted];
    
	_lastCommandRecorded = NO;
	lastCommandPosted.command = command;
	if (sender) {
        if ([sender isKindOfClass:objc_getClass("UINavigationItemButtonView")]) {
            UIAlertView *b = (UIAlertView *)sender;
            lastCommandPosted.uTesterID = [b title];
        } else
        {
            lastCommandPosted.uTesterID = [sender uTesterID];
        }
        
        
        lastCommandPosted.className = [NSString stringWithUTF8String:class_getName([sender class])];
        
        // If subclass of UTTReady class, save inherited class (ignoring UITableView)
        for (NSString *classString in UTTObjCComponentsArray) {
            if ([[sender class] isSubclassOfClass:objc_getClass([classString cStringUsingEncoding:NSStringEncodingConversionAllowLossy])] &&
                ![sender isKindOfClass:[UITableView class]])
                lastCommandPosted.className = classString;
            
        }
	} else {
		lastCommandPosted.uTesterID = nil;
		lastCommandPosted.className = nil;
	}
    
    lastCommandPosted.args = args;
    [self sendNotification:UTTNotificationCommandPosted object:sender];
}

- (NSUInteger) commandCount {
	return [self.commands count];
}

- (UTTCommandEvent*)commandAt:(NSInteger)index {
	NSMutableDictionary* dict = [commands objectAtIndex:index];
	return [[UTTCommandEvent alloc] initWithDict:dict];
	
}

- (void) deleteCommand:(NSInteger) index {
    if (index >= commands.count)
        return;
	[commands removeObjectAtIndex:index];
}


- (UTTCommandEvent*) lastCommand {
	NSInteger index = [commands count] - 1;
	
	NSMutableDictionary* dict = nil;
	if (index > -1) {
		dict = [commands objectAtIndex:index];
		return [[UTTCommandEvent alloc] initWithDict:dict];
	}
	
	return nil;
}

- (UTTCommandEvent*) popCommand {
	NSInteger index = [commands count] - 1;
	
	NSMutableDictionary* dict = nil;
	if (index > -1) {
		dict = [commands objectAtIndex:index];
		[self deleteCommand:index];
		return [[UTTCommandEvent alloc] initWithDict:dict];
	}
	
	return nil;
}


- (NSInteger) firstErrorIndex {
	int i;
	for (i = 0; i < [commands count]; i++) {
		if ([self commandAt:i].lastResult) {
			return i;
		}
	}
	return -1;
}

- (UTTCommandEvent*) lastCommandPosted {
	return lastCommandPosted;
}

- (NSString*) uTesterIDfor:(UIView*)view {
	NSString* value;
	NSValue* key;
	key = [NSValue valueWithPointer:(__bridge const void *)(view)];
	if ((value = [_uTesterIDs objectForKey:key])) {
		return value;
	}
    
    // #utt is replaced with ordinal in UIView+UTTReady in uTesterID
	value = [NSString stringWithFormat:@"#utt"];
	[_uTesterIDs setValue:value forKey:(id)key];
	return value;
}



- (NSMutableDictionary *) componentUTesterIds {
    if (!componentUTesterIds)
        componentUTesterIds = [[NSMutableDictionary alloc] init];
    
    return componentUTesterIds;
}



@end
