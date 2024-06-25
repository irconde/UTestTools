/*  .: UTestTools :.
 ----------------------------------------------------------------------
 Librería de monitorización de la actividad del usuario
 basada en MonkeyTalk, herramienta de testing desarrollada por Gorilla
 Logic, Inc.
 ----------------------------------------------------------------------
 Software distribuido bajo licencia AGPL (GNU Affero General Public
 License) <http://www.gnu.org/licenses/>                                */

#import "UTTWireSender.h"
#import "UTestTools.h"
#import "UTTConvertType.h"
#import "UTTConvertType.h"
#import "UTTUtils.h"
#import "ObjCMongoDB.h"
#import "Reachability.h"
#import "CJSONSerializer.h"
#include <arpa/inet.h>

#define UTTWireCommandKey @"uttcommand"
#define UTTWireComponentTypeKey @"componentType"
#define UTTWireUTesterIdKey @"uTesterId"
#define UTTWireActionKey @"action"
#define UTTWireArgsKey @"args"
#define UTTWireTimeStampKey @"timeStamp"
#define UTTWireCommandRecord @"recordedCommands"

#define LocalhostAddress @"127.0.0.1"
//#define LocalhostPort @"27017"

@implementation UTTWireSender



#pragma mark - Post Command


+ (NSDictionary *) commandsToDict{
    
    NSMutableDictionary *globalDict = [[NSMutableDictionary alloc] init];
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    NSString *componentType = @"";
    
    
    
    for (UTTCommandEvent *commandAux in [[UTestTools sharedUTester] commandList]) {
        
        if ([commandAux.command isEqualToString:UTTCommandLibVersion]|| [commandAux.command isEqualToString:UTTCommandStartSession] ||
            [commandAux.command isEqualToString:UTTCommandOSVersion] || [commandAux.command isEqualToString:UTTCommandDevUDID] ||
            [commandAux.command isEqualToString:UTTCommandDevModel]  || [commandAux.command isEqualToString:UTTCommandGeolocation]) {
            
            
            if ([commandAux.command isEqualToString:UTTCommandStartSession]) {
                
                commandAux.className = commandAux.timestamp;
            }
            
            
            [globalDict setValue:commandAux.className forKey: commandAux.command];
            
        }
        else
        {
            NSMutableDictionary *newCommandDic = [[NSMutableDictionary alloc] init];
            
            
            [newCommandDic setValue:[UTTConvertType convertedComponentFromString:commandAux.className isRecording:YES] forKey:UTTWireComponentTypeKey];
            [newCommandDic setValue:commandAux.uTesterID forKey:UTTWireUTesterIdKey];
            [newCommandDic setValue:commandAux.command forKey:UTTWireActionKey];
            [newCommandDic setValue:commandAux.args forKey:UTTWireArgsKey];
            [newCommandDic setValue:commandAux.timestamp forKey:UTTWireTimeStampKey];
            
            [commands addObject:newCommandDic];
        }
        
    }
    
    [globalDict setValue:commands forKey:UTTWireCommandRecord];
    
    return globalDict;
}

+ (void) saveToJSON: (NSDictionary *) dict {
    
    NSError *error = nil;
    
    NSData *jsonData = [[CJSONSerializer serializer] serializeObject:dict error:&error];
   
    if (error != nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No es guardar los resultados" message:@"Un error de la aplicación ha impedido la creación del fichero JSON para almacenar los datos de la sesión. Pruebe de nuevo más tarde." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Aceptar", nil];
        
        [alert show];
        
        // Guardamos el fichero de log en el directorio tmp de la App
    }
    else
    {
        [jsonData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"sessionLog.json"]] atomically:YES];
    }
    
}

+ (void) sendDataToAddress: (NSString *)IPserver{
    
    
    Reachability *conectionReach = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus netStatus = [conectionReach currentReachabilityStatus];
    
    //Comprobamos que existe conexión a internet
    
    if(netStatus == NotReachable)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No hay conexión a Internet" message:@"La conexión con el servidor no ha sido posible. Verifica tu configuración de Internet para asegurarte de que estás conectado correctamente." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Aceptar", nil];
        
        [alert show];
        
    }
    
    else
        
    {
        
        NSError *error = nil;
        MongoConnection *dbConn = [MongoConnection connectionForServer:IPserver error:&error];
        MongoDBCollection *collection = [dbConn collectionWithName:@"uTestTools.testSessions"];
        
        if (error != nil) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No es posible enviar el Test" message:@"La conexión con el servidor no ha sido posible. El servidor puede estar caido en estos momentos. Prueba a enviar de nuevo el test más tarde." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Aceptar", nil];
            
            [alert show];
            
        }
        else
        {
            
            NSDictionary * testInfo = [self commandsToDict] ;

            
            [collection insertDictionary:testInfo writeConcern:nil error:&error];
            
        }
    }
}



+ (void) sendDataToLocalhost{
    
    [self sendDataToAddress:LocalhostAddress];
    
}




+(void)sendRecordEvent:(UTTCommandEvent *)command {
    
    if ([UTestTools sharedUTester].isWireRecording) {
       


        
        NSString *componentType = [UTTConvertType
                                   convertedComponentFromString:command.className
                                   isRecording:YES];
        
        
        if ([command.uTesterID isEqualToString:@"#1"] ||
            [command.uTesterID isEqualToString:@"#-1"])
            command.uTesterID = @"*";
        
        
        
    
        if ([UTestTools sharedUTester].commandList == nil  || [UTestTools sharedUTester].commandList.count == 0){
            
            [UTestTools sharedUTester].commandList  = [[NSMutableArray alloc] init];
        }
        
        
        [[UTestTools sharedUTester].commandList addObject: command];
        
        
        //-------------------------------------------------------------------------------------------------------------
        
        // CREACIÓN DEL FICHERO TXT DE LOG DE LOS EVENTOS REGISTROS
        
        //-------------------------------------------------------------------------------------------------------------
        
//        
//        NSMutableString *printString = [NSMutableString stringWithString:@""];
//        
//        
//        // Añadimos el componente sobre el que se realiza el evento
//        
//        [printString appendString:[NSString stringWithFormat:@"%@       ",componentType] ];
//        
//        
//        // Añadimos el uTesterID
//        
//        [printString appendString:[NSString stringWithFormat:@"%@       ",command.uTesterID] ];
//        
//        
//        // Añadimos el comando
//        
//        
//        [printString appendString:[NSString stringWithFormat:@"%@       ",command.command] ];
//        
//        
//        
//        
//        // Añadimos los argumentos del comando
//        
//        for (NSString *arg in command.args)
//        {
//            [printString appendString:[NSString stringWithFormat:@"%@       ",arg] ];
//        }
//        
//        // Añadimos el timestamp
//        
//        command.timestamp = [UTTUtils timeStamp];
//        
//        [printString appendString:[NSString stringWithFormat:@"%@",command.timestamp] ];
//        
//        
//        
//        [printString appendString:@"\n"];
//        
//        
//        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentDirectory=[paths objectAtIndex:0];
//        NSString *fileName=[NSString stringWithFormat:@"%@/%@.txt",documentDirectory,@"commands"];
//        NSString *content=printString;
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
//            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
//        }
//        
//        
//        NSFileHandle *fileHandler= [NSFileHandle fileHandleForWritingAtPath:fileName];
//        [fileHandler seekToEndOfFile];
//        [fileHandler writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
//        [fileHandler closeFile];

        
        
        //-------------------------------------------------------------------------------------------------------------

        
        
    }
}


@end
