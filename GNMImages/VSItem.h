//
//  VSItem.h
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VidispineBase.h"

@interface VSItem : NSObject
@property NSMutableDictionary *metadata;

@property NSXMLDocument *doc;

@property bool parserInField;
@property NSString *parserCurrentName;
@property unsigned int level;
@property unsigned int field_at_level;

- (id)initWithXML:(NSXMLDocument *)doc;
- (id)initWithID:(NSString *)vsid connection:(VidispineBase *)base;
- (id)initWithURL:(NSURL *)url;

- (VSValueList *)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key append:(bool)append;

- (void)dump;

@end
