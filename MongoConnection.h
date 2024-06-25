//
//  MongoConnection.h
//  ObjCMongoDB
//
//  Copyright 2012 Paul Melnikow and other contributors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "MongoDBCollection.h"

FOUNDATION_EXPORT NSString * const MongoDBErrorDomain;
FOUNDATION_EXPORT NSString * const MongoDBServerErrorDomain;
FOUNDATION_EXPORT NSInteger const MongoCreateIndexError;

@class MongoWriteConcern;

/**
 Clase utilizada para definir una conexi&oacute;n con una base de datos MongoDB
 */
@interface MongoConnection : NSObject

- (MongoConnection *) init;

/**
 Establece la conexi&oacute;n con la base de datos MongoDB. Para ello, debemos proporcionar una cadena de texto con la direcci&oacute;n IP del servidor.
 */
+ (MongoConnection *) connectionForServer:(NSString *) hostWithPort
                                    error:(NSError * __autoreleasing *) error;

- (BOOL) connectToServer:(NSString *) hostWithPort
                   error:(NSError * __autoreleasing *) error;
- (BOOL) connectToReplicaSet:(NSString *) replicaSet
                   seedArray:(NSArray *) seedArray
                       error:(NSError * __autoreleasing *) error;
- (BOOL) checkConnectionWithError:(NSError * __autoreleasing *) error;
- (BOOL) reconnectWithError:(NSError * __autoreleasing *) error;
- (void) disconnect;


@property (retain) MongoWriteConcern *writeConcern;
@property (assign) NSUInteger maxBSONSize;

/**
 Crea una nueva colecci&oacute;n con un determinado nombre (objeto name de tipo NSString) y la asocia a la conexi&oacute;n ya establecida.
 */
- (MongoDBCollection *) collectionWithName:(NSString *) name;

- (BOOL) dropDatabaseWithName:(NSString *) database;

- (NSDictionary *) runCommandWithName:(NSString *) commandName
                       onDatabaseName:(NSString *) databaseName
                                error:(NSError * __autoreleasing *) error;
- (NSDictionary *) runCommandWithDictionary:(NSDictionary *) dictionary
                             onDatabaseName:(NSString *) databaseName
                                      error:(NSError * __autoreleasing *) error;

- (BOOL) lastOperationWasSuccessful:(NSError * __autoreleasing *) error;
- (NSDictionary *) lastOperationDictionary;
- (NSError *) error;
- (NSError *) serverError;

@end
