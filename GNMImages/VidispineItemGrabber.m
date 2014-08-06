//
//  VidispineItemGrabber.m
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VidispineItemGrabber.h"
#import "VSItem.h"

@implementation VidispineItemGrabber

- (NSManagedObject *) findProjectByID:(NSString *)vsid managedObjectContext:(NSManagedObjectContext *)moc
{
    NSError *error=nil;
    
    NSFetchRequest *projectRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLUTOProject"];
    [projectRequest setPredicate:[NSPredicate predicateWithFormat:@"vsid == %@",vsid]];
    NSArray *projectResults = [moc executeFetchRequest:projectRequest error:&error];
    
    if(projectResults && [projectResults count]>0)
        return [projectResults objectAtIndex:0];
    
    NSLog(@"error looking for project %@: %@",vsid,[error localizedDescription]);
    return nil;
}

- (void)processVidispineElement:(NSXMLElement *)element type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc
{
    NSArray *temp;
    NSXMLElement *el;
    
    NSManagedObject *objectRef = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    
    
    NSLog(@"processVidispineElement: at %@",[element stringValue]);
    
    NSString *vsid = nil;
    temp = [element elementsForName:@"id"];
    if([temp count]<1){
        vsid=[[element attributeForName:@"id"] stringValue];
        if(!vsid){
            abort();
            [moc deleteObject:objectRef];
            return;
        }
    }
    if(vsid){
        [objectRef setValue:vsid forKey:@"vsid"];
    } else {
        el = [temp objectAtIndex: 0];
        [objectRef setValue:[el stringValue] forKey:@"vsid"];
    }
    
    VSItem *item=[[VSItem alloc] initWithID:vsid connection:self];
    
    [item dump];
    temp = [element elementsForName:@"loc"];
    if([temp count]<1){ //we didn't find a specific location
        
    } else {
        el = [temp objectAtIndex: 0];
        [objectRef setValue:[el stringValue] forKey:@"url"];
    }
    
    [objectRef setValue:[[item valueForKey:@"gnm_master_website_headline"] stringValue:nil] forKey:@"name"];
    
    VSValueList *parentCollectionValueList=[item valueForKey:@"__collection"];
    if(!parentCollectionValueList || [parentCollectionValueList count]==0){
        NSLog(@"warning: master found that is not connected to a project");
        //abort();
    } else {
        for(NSString *potentialProjectId in [parentCollectionValueList array]){
            NSManagedObject *parentProject=[self findProjectByID:potentialProjectId managedObjectContext:moc];
            [objectRef setValue:parentProject forKey:@"parent" ];
        }
    }
    
    NSLog(@"added object: name=%@, loc=%@, id=%@",[objectRef valueForKey:@"name"],[objectRef valueForKey:@"url"],[objectRef valueForKey:@"vsid"]);
}

- (void)processVidispineXML:(NSXMLDocument *)xmlDoc type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc
{
    NSXMLElement *root=[xmlDoc rootElement];
    
    NSLog(@"processing returned item XML...");
    NSArray *collectionNodes = [root elementsForName:@"item"];
    
    for(NSXMLElement *n in collectionNodes){
        [self processVidispineElement:n  type:type entityName:entityName managedObjectContext:moc];
    }
    NSLog(@"done.");
}

- (int)getMasters:managedObjectContext
{
    NSString *bodyString=@"<ItemSearchDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"> \
    <field> \
    <name>gnm_type</name> \
    <value>Master</value> \
    </field> \
    </ItemSearchDocument>";
    
    //return [self getGeneric:@"item" entityName:@"PLUTOMaster" bodyString:bodystring managedObjectContext:managedObjectContext];
    [self setDebug:true];
    
    //VSRequest *rq=[[VSRequest alloc] init:@"/collection" method:@"PUT" body:bodystring];
    VSRequest *rq=[[VSRequest alloc] init];
    
    [rq setPath:@"/item"];

    [rq setBody:bodyString];
    [rq setMethod:@"PUT"];
    
    NSXMLDocument *returnedXML=[self makeRequest:rq];
    
    [self processVidispineXML:returnedXML type:@"item" entityName:@"PLUTOMaster" managedObjectContext:managedObjectContext];
    
    return 0;
}

@end
