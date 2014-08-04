//
//  VidispineBase.m
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VidispineBase.h"

@implementation VSRequest
@synthesize path;
@synthesize queryPart;
@synthesize matrixPart;

- (id)init:path queryPart:(NSArray *)q matrixPart:(NSArray *)m
{
    [self setPath:path];
    queryPart= [[NSMutableArray alloc] init];
    if(q){
        for(NSString *i in q){
            [queryPart addObject:i];
        }
    }
    matrixPart=nil;
    if(m){
        for(NSString *i in m){
            [matrixPart addObject:i];
        }
    }
    return self;
}

- (NSString *)finalURLFragment
{
    NSString *queryString = @"";
    for(NSString * i in queryPart){
        queryString=[NSString stringWithFormat:@"%@&%@", queryString, i];
    }
    queryString=[queryString substringFromIndex:1];
    
    NSString *matrixString = @"";
    for(NSString * i in matrixPart){
        queryString=[NSString stringWithFormat:@"%@&%@", matrixString, i];
    }
    queryString=[queryString substringFromIndex:1];
    NSString *ret=[NSString stringWithFormat:@"/API/%@;%@&%@",path,queryString,matrixString];
    
    return ret;
}


@end

size_t download_write_callback(char *ptr, size_t size, size_t nmemb, void *userdata)
{
NSMutableData *buf=(__bridge NSMutableData *)userdata;

    [buf increaseLengthBy:(size*nmemb)];
    [buf appendBytes:ptr length:(size*nmemb)];
    
    return size;
}

@implementation VidispineBase
@synthesize hostname;
@synthesize port;
@synthesize username;
@synthesize passwd;

/*make a request and return parsed XML data from it, or NULL*/
- (NSXMLDocument *)makeRequest:(VSRequest *)req
{
    if(!req){
        return nil;
    }

    NSString *finalURL=[NSString stringWithFormat:@"http://%@:%@/%@",hostname,port,[req finalURLFragment]];
    
    CURL *curl = curl_easy_init();

    NSMutableData *dataBuffer = [[NSMutableData alloc] init];
    
    curl_easy_setopt(curl,CURLOPT_URL,[finalURL cStringUsingEncoding:NSUTF8StringEncoding]);
    if(username)
        curl_easy_setopt(curl,CURLOPT_USERNAME,[username cStringUsingEncoding:NSUTF8StringEncoding]);
    if(passwd)
        curl_easy_setopt(curl,CURLOPT_USERNAME,[passwd cStringUsingEncoding:NSUTF8StringEncoding]);

    curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,&download_write_callback);
    curl_easy_setopt(curl,CURLOPT_WRITEDATA,(__bridge void *)dataBuffer);
    
    NSError *parseError=nil;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:dataBuffer options:NSXMLDocumentTidyXML error:&parseError];
    
    if(doc==NULL){
        self.lastError=parseError;
    }
    
    return doc;
}


@end
