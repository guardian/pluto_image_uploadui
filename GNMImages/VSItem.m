//
//  VSItem.m
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VSItem.h"

@implementation VSItem
//@synthesize parserInField;

- (void)recurseXMLNodes:(NSXMLElement *)el
{
    //static unsigned int level=0;
    NSLog(@"at %@, level %d",[el localName],_level);

    //if(_parserInField){
        if([[el localName] compare:@"name"]==0){
            NSLog(@"got name: %@",[el stringValue]);
            _parserCurrentName=[el stringValue];
            /*--_level;
             return;*/
            return;
        }
        if([[el localName] compare:@"value"]==0){
            NSLog(@"got value: %@ for %@",[el stringValue],_parserCurrentName);
            
            [self setValue:[el stringValue] forKey:_parserCurrentName append:true];
            //[_metadata setValue:[el stringValue] forKey:_parserCurrentName];
            return;
            
        }
    //}
    
    if([el childCount]>0){
        for(NSXMLElement *c in [el children]){
            ++_level;
            [self recurseXMLNodes:c];
            --_level;
            if(_level==_field_at_level)
                _parserInField = false;
        }
    }
    
    if([[el localName] compare:@"field"]==0){
        _parserInField=true;
        //--_level;
        _field_at_level=_level;
        return;
    }
    //--_level;
}

- (id)initWithXML:(NSXMLDocument *)doc
{
    _metadata = [[NSMutableDictionary alloc] init];
    _doc = doc;
    _parserInField=false;
    [self recurseXMLNodes:[doc rootElement]];
    return self;
}

- (id)initWithID:(NSString *)vsid connection:(VidispineBase *)base
{
    VSRequest *req=[[VSRequest alloc] init];
    
    NSString *pathstring=[NSString stringWithFormat:@"/item/%@/metadata",vsid];
    [req setPath:pathstring];
    [req setMethod:@"GET"];
    
    NSXMLDocument *doc=[base makeRequest:req];
    
    return [self initWithXML:doc];
}

- (id)initWithURL:(NSURL *)url
{
    return self;
}

- (VSValueList *)valueForKey:(NSString *)key
{
    return [_metadata valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key append:(bool)append
{
    VSValueList *currentValue=[_metadata objectForKey:key];
    if(currentValue==nil || append==false){
        currentValue = [[VSValueList alloc] init];
    }
    
    [currentValue addObject:value];
    [_metadata setObject:currentValue forKey:key];
}

- (void)dump
{
    NSEnumerator *enumerator = [_metadata keyEnumerator];
    NSString *key;
    
    NSLog(@"VSItem::dump");
    while ((key = [enumerator nextObject])) {
        //NSDictionary *tmp = [bigUglyDictionary objectForKey:key];
        VSValueList *l = [_metadata objectForKey:key];
        NSLog(@"\t%@ = %@",key,[l stringValue:@","]);
    }
    NSLog(@"-----------------------------------");
}

- (void)mapToCoreDataEntity:(NSManagedObject *)entity fieldMapping:(NSDictionary *)mapping
{
    NSEnumerator *e = [mapping keyEnumerator];
    NSString *sourceField;
    
    while((sourceField = [e nextObject])) {
        VSValueList *vl = [_metadata valueForKey:sourceField];
        if(!vl) continue;
        
        NSString *destField = [mapping valueForKey:sourceField];
        [entity setValue:[vl stringValue:@","] forKey:destField];
        
    }
}
@end
