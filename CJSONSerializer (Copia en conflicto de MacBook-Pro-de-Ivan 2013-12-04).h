//
//  CJSONSerializer.h
//  TouchCode
//
//  Created by Jonathan Wight on 12/07/2005.
//  Copyright 2005 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

enum {
    kJSONSerializationOptions_EncodeSlashes = 0x01,
};
typedef NSUInteger EJSONSerializationOptions;

/**
 Clase que permite la serialización o codificación de una determinada información en formato JSON.
 */


@interface CJSONSerializer : NSObject {
}

@property (readwrite, nonatomic, assign) EJSONSerializationOptions options;

+ (CJSONSerializer *)serializer;

- (BOOL)isValidJSONObject:(id)inObject;

/**
 Codifica en JSON los datos almacenados en un objeto compatible (generalmente NSNull, NSNumber, NSString y NSDictionary) y genera como resultado un objeto NSData que contiene el JSON serializado.
 */
- (NSData *)serializeObject:(id)inObject error:(NSError **)outError;

- (NSData *)serializeNull:(NSNull *)inNull error:(NSError **)outError;
- (NSData *)serializeNumber:(NSNumber *)inNumber error:(NSError **)outError;
- (NSData *)serializeString:(NSString *)inString error:(NSError **)outError;
- (NSData *)serializeArray:(NSArray *)inArray error:(NSError **)outError;
- (NSData *)serializeDictionary:(NSDictionary *)inDictionary error:(NSError **)outError;

@end

extern NSString *const kJSONSerializerErrorDomain /* = @"CJSONSerializerErrorDomain" */;

typedef enum {
    CJSONSerializerErrorCouldNotSerializeDataType = -1,
    CJSONSerializerErrorCouldNotSerializeObject = -2,
} CJSONSerializerError;
