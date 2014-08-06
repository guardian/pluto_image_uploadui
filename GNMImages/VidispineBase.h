//
//  VidispineBase.h
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface VSValueList : NSObject
@property NSMutableArray *list;

- (NSString *)stringValue:(NSString *)delim;
- (NSUInteger)count;

- (NSArray *)array;
- (void)addObject:(id)object;
@end

@interface VSRequest : NSObject
@property NSString *path;
@property NSMutableArray *queryPart;
@property NSMutableArray *matrixPart;
@property NSString *method;
@property NSString *body;
@property NSString *rawURL;

- (id)init:path queryPart:(NSArray *)q matrixPart:(NSArray *)m;
- (NSString *)finalURLFragment;

@end

@interface VidispineBase : NSObject
@property bool debug;
@property NSString *hostname;
@property NSString *port;
@property NSString *username;
@property NSString *passwd;
@property NSString *cantemoServer;

@property NSError *lastError;

- (id)init:(NSString *)hostname port:(NSString *)port username:(NSString *)username password:(NSString *)passwd;
- (NSXMLDocument *)makeRequest:(VSRequest *)req;
- (NSError *)lastError;

@end
