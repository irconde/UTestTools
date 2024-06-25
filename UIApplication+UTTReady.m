/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UIApplication+UTTReady.h"
#import <objc/runtime.h>
#import "UIView+UTTReady.h"
#import "UTestTools.h"
#import "UTTUtils.h"
#import "NSString+UTestTools.h"
#import "UTTConvertType.h"
#import "UTTWireSender.h"
#import "UTTDevice.h"

@implementation UIApplication (UTTReady)

+ (void)load {
	if (self == [UIApplication class]) {
		NSLog(@"Cargando UTestTools...");
		
        Method originalMethod = class_getInstanceMethod(self, @selector(sendEvent:));
        Method replacedMethod = class_getInstanceMethod(self, @selector(uttSendEvent:));
        method_exchangeImplementations(originalMethod, replacedMethod);
		[[NSNotificationCenter defaultCenter] addObserver:self	
												 selector:@selector(initUTestTools:)
													 name:UIApplicationDidFinishLaunchingNotification object:nil];
        
        Method originalBgMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method replacedBgMethod = class_getInstanceMethod(self, @selector(uttSetDelegate:));
        method_exchangeImplementations(originalBgMethod, replacedBgMethod);
	
	}
}

- (void) uttSetDelegate:(id <UIApplicationDelegate>) del {
	Method originalMethod = class_getInstanceMethod([del class], @selector(applicationDidEnterBackground:));
	if (originalMethod) {
		IMP origImp = method_getImplementation(originalMethod);
		Method replacedMethod = class_getInstanceMethod([self class], @selector(uttApplicationDidEnterBackground:));
		IMP replImp = method_getImplementation(replacedMethod);
		
		if (origImp != replImp) {
			method_setImplementation(originalMethod, replImp);
			class_addMethod([del class], @selector(origApplicationDidEnterBackground:), origImp,"v@");
		}
	}
    
    Method originalForegroundMethod = class_getInstanceMethod([del class], @selector(applicationWillEnterForeground:));
	if (originalForegroundMethod) {
		IMP origImp = method_getImplementation(originalForegroundMethod);
		Method replacedForegroundMethod = class_getInstanceMethod([self class], @selector(uttApplicationWillEnterForeground:));
		IMP replImp = method_getImplementation(replacedForegroundMethod);
		
		if (origImp != replImp) {
			method_setImplementation(originalForegroundMethod, replImp);
			class_addMethod([del class], @selector(origApplicationWillEnterForeground:), origImp,"v@");
		}
	}
    
	[self uttSetDelegate:del];
    
}

- (void)uttApplicationWillEnterForeground:(UIApplication *)application {
    if ([self respondsToSelector:@selector(uttApplicationWillEnterForeground:)]) {
        [self uttApplicationWillEnterForeground:application];
    }
    
}

- (void)uttApplicationDidEnterBackground:(UIApplication *)application {
    if ([self respondsToSelector:@selector(uttApplicationDidEnterBackground:)]) {
        [self uttApplicationDidEnterBackground:application];
    }
    

}

+ (void) initUTestTools:(NSNotification*)notification {
	
    // IVAN: Registramos en el Log el comienzo de la sesion
    
    UTTCommandEvent *startEvent = [[UTTCommandEvent alloc] init:UTTCommandStartSession className:@"*" uTesterID:@"*" args:nil];
    
    [UTTWireSender sendRecordEvent:startEvent];
    
    
    // IVAN: Registramos qué versión de la librería ha registrado los eventos

    UTTCommandEvent *libVersion =[[UTTCommandEvent alloc] init:UTTCommandLibVersion className:[UTTDevice os] uTesterID:@"*" args:nil];
    [UTTWireSender sendRecordEvent:libVersion];
    
    
    // IVAN; Registramos la versión del sistema operativo
    
    UTTCommandEvent *osVersion =[[UTTCommandEvent alloc] init:UTTCommandOSVersion className:[UTTDevice getOSVersion] uTesterID:@"*" args:nil];
    
    [UTTWireSender sendRecordEvent:osVersion];
    
    // IVAN: Registramos el tipo de dispositivo físico usado
    
    UTTCommandEvent *hwModel = [[UTTCommandEvent alloc] init:UTTCommandDevModel className:[UTTDevice getDeviceModel] uTesterID:@"*" args:nil];
    
    [UTTWireSender sendRecordEvent:hwModel];
    
    
    // IVAN: Registramos el identificador único del dispositivo físico
    
    
    UTTCommandEvent *hwUDID = [[UTTCommandEvent alloc] init:UTTCommandDevUDID className:[UTTDevice getUDID] uTesterID:@"*" args:nil];
    
    [UTTWireSender sendRecordEvent:hwUDID];
    
    

}



- (void)uttSendEvent:(UIEvent *)event {
    
	[[UTestTools sharedUTester] handleEvent:event];
	
	[self uttSendEvent:event];

	
}

@end
