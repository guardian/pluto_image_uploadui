//
//  VidispineBase.h
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <curl/curl.h>

@interface VSRequest : NSObject
@property NSString *path;
@property NSMutableArray *queryPart;
@property NSMutableArray *matrixPart;

- (id)init:path queryPart:(NSArray *)q matrixPart:(NSArray *)m;
- (NSString *)finalURLFragment;

@end

@interface VidispineBase : NSObject

@property NSString *hostname;
@property NSString *port;
@property NSString *username;
@property NSString *passwd;
@property NSError *lastError;

- (NSXMLDocument *)makeRequest:(VSRequest *)req;
- (NSError *)lastError;

@end
