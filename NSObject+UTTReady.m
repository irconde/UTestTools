/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import <objc/runtime.h>
#import "NSObject+UTTReady.h"

#import "UIControl+UTTReady.h"
#import "NSObject+UTTReady.h"


@implementation NSObject (UTTReady)
+ (void)load {
    if (self == [NSObject class]) {	
		Method originalMethod = class_getInstanceMethod(self, @selector(init));
		Method replacedMethod = class_getInstanceMethod(self, @selector(uttInit));		
        method_exchangeImplementations(originalMethod, replacedMethod);		
    }
}


- (id)uttInit {
	
	if (self == [self uttInit]) {	

	}
	return self;
}

- (void) interceptMethod:(SEL)orig withClass:(Class)class types:(char*) types {
    @autoreleasepool {
		Method originalMethod = class_getInstanceMethod([self class], orig);
		IMP origImp = nil;
		if (originalMethod) {
			origImp = method_getImplementation(originalMethod);
		}
		const char* origName = sel_getName(orig);
		Method replaceMethod = class_getInstanceMethod(class, NSSelectorFromString([NSString stringWithFormat:@"utt_%s", origName]));
		IMP replImp = method_getImplementation(replaceMethod);
		
		if (origImp != replImp) {
			if (originalMethod) {
				NSString* newName = [NSString stringWithFormat:@"orig_%s", origName];
				method_setImplementation(originalMethod, replImp);
				class_addMethod([self class], NSSelectorFromString(newName), origImp,types);		
			} else {
				class_addMethod([self class], orig, replImp,types);
			}
			
		}
    }
}

- (void) interceptMethod:(SEL)orig withMethod:(SEL)repl ofClass:(Class)class renameOrig:(SEL)newName types:(char*) types {
	Method originalMethod = class_getInstanceMethod([self class], orig);
	IMP origImp = nil;
	if (originalMethod) {
		origImp = method_getImplementation(originalMethod);
	}
	Method replacedMethod = class_getInstanceMethod(class, repl);
	IMP replImp = method_getImplementation(replacedMethod);
		
	if (origImp != replImp) {
		if (originalMethod) {
			method_setImplementation(originalMethod, replImp);
			class_addMethod([self class], newName, origImp,types);		
		} else {
			class_addMethod([self class], orig, replImp,types);
		}

	}
}

- (BOOL) uttHasMethod:(SEL) selector {
	return class_getInstanceMethod([self class], selector) != nil;
}

+ (void) swizzle:(NSString *)original with:(NSString *)new for:(Class)forClass {
    Method originalMethod = class_getInstanceMethod(forClass, NSSelectorFromString(original));
    Method replacedMethod = class_getInstanceMethod(forClass, NSSelectorFromString(new));
    method_exchangeImplementations(originalMethod, replacedMethod);
}

@end
