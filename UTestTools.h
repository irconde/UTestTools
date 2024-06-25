/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */


/** \mainpage Documentaci&oacute;n de UTestTools para iOS
 * <div style="border:1px solid black; font-size:12pt;width:50%; margin:5%;padding:5%;text-align:center">
 * <div stle="margin-below:24pt"><div>UTestTools es una librer&iacute;a de monitorizaci&oacute;n de la actividad del usuario basada en Monkey Talk, herramienta de testing desarrollada po Gorilla Logic, Inc.</div> El API ha sido desarrollado dentro del proyecto GOAL, con c&oacute;digo 64563, cofinanciado por CDTI dentro del Programa FEDER INNTERCONECTA, convocatoria Galicia 2013</div>
 * Consulta m&aacute;s informaci&oacute;n acerca del proyecto desde la siguiente URL: http://www.innterconectagoal.es
 * </div>
 */


#import "UTTConstants.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class UTTCommandEvent;

/**
 Clase principal del API.
 */
@interface UTestTools : NSObject <CLLocationManagerDelegate>{

    /**
     Listado de comandos grabado durante la sesi&oacute;n de pruebas.
     */
	NSMutableArray* commands;
    NSString *commandSpeed;
    BOOL isWireRecording;


    NSMutableArray *foundComponents;
    NSMutableArray *uTesterComponents;
    NSMutableDictionary *componentUTesterIds;
    UTTCommandEvent *currentTapCommand;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
}	


/**
 Acceso a la instancia del API, que es &uacute;nica (Patr&oacute;n Singleton)
 */
+ (UTestTools*) sharedUTester;
- (void) continueMonitoring;
/**
 Borrado de los comandos grabados durante una sesi&oacute;n de pruebas hasta un determinado instante.
 */
- (void) clear;

/**
 Gestión de eventos de toque y movimiento.
 */
- (void) handleEvent:(UIEvent*) event;
+ (void) recordFrom:(UIView*)source command:(NSString*)command;
+ (void) recordFrom:(UIView*)source command:(NSString*)command args:(NSArray*)args;
/**
 Grabaci&oacute;n de un nuevo comando con el nombre command, a partir de un evento registrado sobre una vista (sender) con una serie de caracter&iacute;sticas (args).
 */
- (void) postCommandFrom:(UIView*)sender command:(NSString*)command args:(NSArray*)args;
/**
 Recuperar un comando de una posici&oacute;n concreta (index) dentro de la lista de comandos grabada durante la sesi&oacute;n de pruebas.
 */
- (UTTCommandEvent*)commandAt:(NSInteger)index;
/**
 N&uacute;mero de comandos grabados
 */
- (NSUInteger) commandCount;
/**
 Borrado de un comando identificado por el &iacute;ndice dentro de la lista de comandos grabados.
 */
- (void) deleteCommand:(NSInteger) index;
- (UTTCommandEvent*) lastCommand;

- (NSInteger) firstErrorIndex;
/**
 &Uacute;ltimo comando de sesi&oacute;n grabado.
 */
- (UTTCommandEvent*) lastCommandPosted;
- (UTTCommandEvent*) popCommand;

/**
 Identificador asociado a un objeto UIView.
 */
- (NSString*) uTesterIDfor:(UIView*)view;


- (void) receivedRotate: (NSNotification*) notification;
+ (void) recordEvent:(UTTCommandEvent*)event;
- (void) recordFrom:(UIView*)source command:(NSString*)command args:(NSArray*)args post:(BOOL)post;

+ (void) buildCommand:(UTTCommandEvent*)event;

/**
 Orden a la clase UTTWireSender para que añada el nuevo comando creado a la lista de comandos-
 */
+ (void) sendRecordEvent:(UTTCommandEvent *)event;
- (void) emptyRecordQueue;

@property (nonatomic, strong) NSMutableArray* commands;
@property (nonatomic, strong) NSString *commandSpeed;
@property (nonatomic, readwrite) BOOL isWireRecording;

@property (nonatomic, strong) NSMutableArray *commandQueue;
@property (nonatomic, strong) NSMutableArray *commandList;

@property (nonatomic, strong) NSMutableArray *foundComponents;
@property (nonatomic, strong) NSMutableArray *uTesterComponents;
@property (nonatomic, readwrite) UIDeviceOrientation currentOrientation;

@property (nonatomic, strong) NSMutableDictionary *componentUTesterIds;
@property (nonatomic, strong) UTTCommandEvent *currentTapCommand;





@end

