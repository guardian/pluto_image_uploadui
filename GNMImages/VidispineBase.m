//
//  VidispineBase.m
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VidispineBase.h"

@implementation VSValueList

- (id)init
{
    _list = [[NSMutableArray alloc] init];
    return self;
}

-(NSString *)stringValue:(NSString *)delim
{
    NSString *rtn=@"";
    if(delim==nil)
        delim = @"";
    
    for(NSString *v in _list){
        rtn=[NSString stringWithFormat:@"%@%@%@",rtn,delim,v];
    }
    
    if([delim compare:@""] ==0)
        return rtn;
    
    return [rtn substringFromIndex:1];
}

- (NSUInteger)count
{
    return [_list count];
}

- (void)addObject:(id)object
{
    [_list addObject:object];
}

- (NSArray *)array
{
    return [NSArray arrayWithArray:_list];
}
@end

@implementation VSRequest
@synthesize path;
@synthesize queryPart;
@synthesize matrixPart;
@synthesize rawURL;
@synthesize method;

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

    NSString *queryString = @"?";
    for(NSString * i in queryPart){
        queryString=[NSString stringWithFormat:@"%@&%@", queryString, i];
    }
    if([queryString length]>1)
        queryString = @"";
    
    if([queryString length]>0)
        queryString=[queryString substringFromIndex:1];
    
    NSString *matrixString = @";";
    for(NSString * i in matrixPart){
        matrixString=[NSString stringWithFormat:@"%@&%@", matrixString, i];
    }
    if([matrixString length]==1)
        matrixString = @"";
    
    if([matrixString length]>0)
        matrixString=[matrixString substringFromIndex:1];
    
    if([path characterAtIndex:0] == '/')
        path = [path substringFromIndex:1];
    
    NSString *ret=[NSString stringWithFormat:@"API/%@%@%@",path,matrixString,queryString];
    
    return ret;
}


@end

size_t download_write_callback(char *ptr, size_t size, size_t nmemb, void *userdata)
{
    NSMutableData *buf=(__bridge NSMutableData *)userdata;

    //[buf increaseLengthBy:(size*nmemb)];
    [buf appendBytes:ptr length:(size*nmemb)];
    
    //NSLog(@"download_write_callback: got %s",ptr);
    return size*nmemb;
}

size_t upload_read_callback(char *ptr, size_t size, size_t nmemb, void *userdata)
{
    static long uploaded_bytes = 0;
    NSData *buf=(__bridge NSData *)userdata;
    
    if(uploaded_bytes==[buf length]){
        uploaded_bytes = 0;
        return 0; //tell the library to stop if we've uploaded everything
    }
    
    NSRange uploadRange;
    uploadRange.location = uploaded_bytes;
    uploadRange.length = size*nmemb;
    
    if([buf length]<uploadRange.location+uploadRange.length){
        uploadRange.length=[buf length]-uploadRange.location;
    }
    
    [buf getBytes:ptr range:uploadRange];
    uploaded_bytes += uploadRange.length;
    
    return uploadRange.length;
}
@implementation VidispineBase
@synthesize hostname;
@synthesize port;
@synthesize username;
@synthesize passwd;
@synthesize debug;
@synthesize cantemoServer;

- (id)init:(NSString *)hst port:(NSString *)pt username:(NSString *)usr password:(NSString *)pwd
{
    hostname=hst;
    port=pt;
    username=usr;
    passwd=pwd;
    
    cantemoServer = @"cantemoportal.dc1.gnm.int";
    return self;
}

/*make a request and return parsed XML data from it, or NULL*/
- (NSXMLDocument *)makeRequest:(VSRequest *)req
{
    if(!req){
        NSLog(@"ERROR: VisidpineBase::makeRequest - req cannot be nil");
        return nil;
    }

    NSString *finalURL = nil;
    if([req rawURL]){
        finalURL = [req rawURL];
    } else {
        finalURL=[NSString stringWithFormat:@"http://%@:%@/%@",hostname,port,[req finalURLFragment]];
    }
    
    if(debug){
        NSLog(@"connecting to %@",finalURL);
    }
    CURL *curl = curl_easy_init();

    NSMutableData *dataBuffer = [[NSMutableData alloc] init];
    
    curl_easy_setopt(curl,CURLOPT_URL,[finalURL cStringUsingEncoding:NSUTF8StringEncoding]);
    if(username)
        curl_easy_setopt(curl,CURLOPT_USERNAME,[username cStringUsingEncoding:NSUTF8StringEncoding]);
    if(passwd)
        curl_easy_setopt(curl,CURLOPT_PASSWORD,[passwd cStringUsingEncoding:NSUTF8StringEncoding]);

    curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,&download_write_callback);
    curl_easy_setopt(curl,CURLOPT_WRITEDATA,(__bridge void *)dataBuffer);
    
    if([[req method] caseInsensitiveCompare:@"PUT"]==0){
        curl_easy_setopt(curl,CURLOPT_PUT,1L);
        struct curl_slist *requestHeaders = NULL;
        requestHeaders = curl_slist_append (requestHeaders,"Content-Type: application/xml");
        
        curl_easy_setopt(curl,CURLOPT_HTTPHEADER,requestHeaders);
        curl_easy_setopt(curl,CURLOPT_UPLOAD,1L);
        NSData *bodydata=[[req body] dataUsingEncoding:NSUTF8StringEncoding];
        curl_easy_setopt(curl,CURLOPT_READDATA,bodydata);
        curl_easy_setopt(curl,CURLOPT_READFUNCTION,&upload_read_callback);
        //curl_easy_setopt(curl,CURLOPT_CUSTOMREQUEST,[[req method] cStringUsingEncoding:NSUTF8StringEncoding]);
        //curl_easy_setopt(curl,CURLOPT_POSTFIELDS,[req body]);
    }
    curl_easy_perform(curl);
    
    long responseCode = -1;
    
    CURLcode r = curl_easy_getinfo(curl,CURLINFO_RESPONSE_CODE,&responseCode);
    
    NSLog(@"response code from server: %lu",responseCode);
    
    NSError *parseError=nil;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:dataBuffer options:NSXMLDocumentTidyXML error:&parseError];

    if(debug){
        //NSLog(@"data returned from server:\n%@",[[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding]);
        NSData *xmlString = [doc XMLData];
        NSLog(@"xml data:\n%@",[[NSString alloc] initWithData:xmlString encoding:NSUTF8StringEncoding]);
        
    }
    
    if(doc==NULL){
        self.lastError=parseError;
    }
    
    return doc;
}


@end
