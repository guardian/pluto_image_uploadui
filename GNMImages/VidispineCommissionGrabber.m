//
//  VidispineCommissionGrabber.m
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VidispineCommissionGrabber.h"

/*
 <ItemSearchDocument xmlns="http://xml.vidispine.com/schema/vidispine">
     <field>
         <name>gnm_type</name>
         <value>Commission</value>
     </field>
     <field>
         <name>gnm_commission_status</name>
         <value>In production</value>
         <value>New</value>
     </field>
 </ItemSearchDocument>
 */
@implementation VidispineCommissionGrabber

- (void)processVidispineElement:(NSXMLElement *)element type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc
{
    NSArray *temp;
    NSXMLElement *el;
   
    NSManagedObject *commissionRef = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    
    
    NSLog(@"processVidispineElement: at %@",[element stringValue]);
    
    NSString *vsid = nil;
    temp = [element elementsForName:@"id"];
    if([temp count]<1){
        vsid=[[element attributeForName:@"id"] stringValue];
        if(!vsid){
            [moc deleteObject:commissionRef];
            return;
        }
    }
    if(vsid){
        [commissionRef setValue:vsid forKey:@"vsid"];
    } else {
        el = [temp objectAtIndex: 0];
        [commissionRef setValue:[el stringValue] forKey:@"vsid"];
    }
    
    temp = [element elementsForName:@"name"];
    if([temp count]<1){
        NSLog(@"WARNING: found %@ with no name.",type);
        [commissionRef setValue:@"(no name)" forKey:@"name"];
    } else {
        el = [temp objectAtIndex: 0];
        [commissionRef setValue:[el stringValue] forKey:@"name"];
    }
    
    
    temp = [element elementsForName:@"loc"];
    if([temp count]<1){ //we didn't find a specific location

    } else {
        el = [temp objectAtIndex: 0];
        [commissionRef setValue:[el stringValue] forKey:@"url"];
    }
    
    NSLog(@"added object: name=%@, loc=%@, id=%@",[commissionRef valueForKey:@"name"],[commissionRef valueForKey:@"url"],[commissionRef valueForKey:@"vsid"]);
}

- (void)processVidispineXML:(NSXMLDocument *)xmlDoc type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc
{
    NSXMLElement *root=[xmlDoc rootElement];
 
    NSLog(@"processing returned XML...");
    NSArray *collectionNodes = [root elementsForName:@"collection"];
    
    if([collectionNodes count]==0){
        NSArray *itemNodes = [root elementsForName:@"item"];
        for(NSXMLElement *n in itemNodes){
            [self processVidispineElement:n  type:type entityName:entityName managedObjectContext:moc];
        }
    }

    for(NSXMLElement *n in collectionNodes){
        [self processVidispineElement:n  type:type entityName:entityName managedObjectContext:moc];
    }
    NSLog(@"done.");
}

- (int)getCommissions:managedObjectContext
{
    NSString *bodystring=@"<ItemSearchDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"> \
    <field> \
    <name>gnm_type</name> \
    <value>Commission</value> \
    </field> \
    <field> \
    <name>gnm_commission_status</name> \
    <value>In production</value> \
    <value>New</value> \
    </field> \
    </ItemSearchDocument>";
    
    return [self getGeneric:@"collection" entityName:@"PLUTOCommission" bodyString:bodystring managedObjectContext:managedObjectContext];
}

- (int)getProjects:managedObjectContext
{
    NSString *bodystring=@"<ItemSearchDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"> \
    <field> \
    <name>gnm_type</name> \
    <value>Project</value> \
    </field> \
    <field> \
    <name>gnm_project_status</name> \
    <value>In production</value> \
    <value>New</value> \
    </field> \
    </ItemSearchDocument>";
    
    return [self getGeneric:@"collection" entityName:@"PLUTOProject" bodyString:bodystring managedObjectContext:managedObjectContext];
}

- (int)getMasters:managedObjectContext
{
    NSString *bodystring=@"<ItemSearchDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"> \
    <field> \
    <name>gnm_type</name> \
    <value>Master</value> \
    </field> \
    </ItemSearchDocument>";
    
    return [self getGeneric:@"item" entityName:@"PLUTOMaster" bodyString:bodystring managedObjectContext:managedObjectContext];
}

-(int)getGeneric:(NSString *)type entityName:(NSString *)entityName bodyString:(NSString *)bodyString managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    [self setDebug:true];
    
//VSRequest *rq=[[VSRequest alloc] init:@"/collection" method:@"PUT" body:bodystring];
    VSRequest *rq=[[VSRequest alloc] init];

    [rq setPath:@"/collection"];
    if([type caseInsensitiveCompare:@"item"]==0){
        [rq setPath:@"/item"];
    }
    [rq setBody:bodyString];
    [rq setMethod:@"PUT"];
    
    NSXMLDocument *returnedXML=[self makeRequest:rq];
    
    [self processVidispineXML:returnedXML type:type entityName:entityName managedObjectContext:managedObjectContext];
    
    return 0;
}

- (NSString *)getParentID:(NSXMLDocument *)metadoc
{
    NSLog(@"getParentID");
    NSXMLElement *root= [metadoc rootElement];
    
    NSArray *tsr = [root elementsForName:@"timespan"];
    NSLog(@"got %lu results for timespan",(unsigned long)[tsr count]);
    if([tsr count]==0) return nil;
    
    NSXMLElement *timespanElement = [tsr objectAtIndex:0];
    
    NSArray *results = [timespanElement elementsForName:@"field"];
    NSLog(@"got %lu results for field",(unsigned long)[results count]);
    
    for(NSXMLElement *field in results){
        NSArray *nameResults = [field elementsForName:@"name"];
        //NSLog(@"got %lu results for name",(unsigned long)[nameResults count]);
        if([nameResults count]==0) continue;
        
        NSXMLElement *nameElement = [nameResults objectAtIndex:0];
        //NSLog(@"got %@ for name",[nameElement stringValue]);
        
        if([[nameElement stringValue] compare:@"__parent_collection"]==0){
            NSArray *valueResults = [field elementsForName:@"value"];
            NSLog(@"got %lu results for value of __parent_collection",(unsigned long)[valueResults count]);
            if([valueResults count]==0) continue;
            
            NSXMLElement *valueElement = [valueResults objectAtIndex:0];
            
            NSString *parentID = [valueElement stringValue];
            NSLog(@"found parent collection %@",parentID);
            return parentID;
        }
    }
    return nil;
}

- (NSString *)getFieldValue:(NSString *)fieldName xmlDoc:(NSXMLDocument *)doc
{
    NSXMLElement *root=[doc rootElement];
    
    NSArray *fieldNodes = [root elementsForName:@"field"];
    NSLog(@"getFieldValue: found %lu results for field nodes",(unsigned long)[fieldNodes count]);
                           for(NSXMLElement *n in fieldNodes){
                               NSArray *nameNodes = [n elementsForName:@"name"];
                               if([nameNodes count]>0 && [[[nameNodes objectAtIndex:0] stringValue] compare:fieldName]==0){
                                   NSArray *valueNodes = [n elementsForName:@"value"];
                                   return [[valueNodes objectAtIndex:0] stringValue];
                               }
                           }
                           return nil;
}
                           
- (void)fixupMasters:(NSManagedObjectContext *)moc
{
    NSLog(@"fixupMasters");
    
    /* build a request to find all PLUTO masters */
    NSFetchRequest *projectRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLUTOMaster"];
    
    NSError *error = nil;
    
    NSArray *results = [moc executeFetchRequest:projectRequest error:&error];
    
    if(error){
        NSLog(@"got error searching for masters: %@",[error localizedDescription]);
    }
    NSLog(@"got %lu results for all masters",(unsigned long)[results count]);
    
    /* loop through all projects in the system*/
    for(NSManagedObject *object in results){
        /*get metadata for the project*/
        //NSString *uri = [NSString stringWithFormat:@"%@/metadata",[object valueForKey:@"url"]];
        VSRequest *rq=[[VSRequest alloc] init];
        
        //[rq setRawURL:uri];
        NSString *uri = [NSString stringWithFormat:@"/item/%@/metadata",[object valueForKey:@"vsid"]];
        NSLog(@"looking up %@",uri);
        [rq setPath:uri];
        [rq setBody:nil];
        [rq setMethod:@"GET"];
        //[self setDebug:false];
        
        NSXMLDocument *metadoc = [self makeRequest:rq];
        
        /*find the Vidispine ID of the parent collection*/
        NSString *parentID = [self getParentID:metadoc];
        
        NSString *title = [self getFieldValue:@"title" xmlDoc:metadoc];
        NSLog(@"got title: %@",title);
        
        if(title)
            [object setValue:title forKey:@"name"];

        
        if(!parentID)
            continue;
        
        /*find the object pointer of the commission with the same Vidispine ID as the parent*/
        NSFetchRequest *commissionRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLUTOProject"];
        [commissionRequest setPredicate:[NSPredicate predicateWithFormat:@"vsid == %@",parentID]];
        NSArray *commissionResults = [moc executeFetchRequest:commissionRequest error:&error];
        
        NSLog(@"got %lu results for projects matching %@",(unsigned long)[commissionResults count],parentID);
        
        for(NSManagedObject *commission in commissionResults){
            /*add the current project (in variable 'object') to the found commission*/
            NSMutableSet *existingChildren = [commission valueForKey:@"children"];
            [existingChildren addObject:object];
            [commission setValue:existingChildren forKey:@"children"];
        }
    }
   
}
- (void)fixupProjects:(NSManagedObjectContext *)moc
{
    /* build a request to find all PLUTO projects */
    NSFetchRequest *projectRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLUTOProject"];

    NSError *error = nil;
    
    NSArray *results = [moc executeFetchRequest:projectRequest error:&error];
    
    if(error){
        NSLog(@"got error searching for projects: %@",[error localizedDescription]);
    }
    NSLog(@"got %lu results for all projects",(unsigned long)[results count]);
    
    /* loop through all projects in the system*/
    for(NSManagedObject *object in results){
        /*get metadata for the project*/
        //NSString *uri = [NSString stringWithFormat:@"%@/metadata",[object valueForKey:@"url"]];
        VSRequest *rq=[[VSRequest alloc] init];
        
        //[rq setRawURL:uri];
        NSString *uri = [NSString stringWithFormat:@"/collection/%@/metadata",[object valueForKey:@"vsid"]];
        NSLog(@"looking up %@",uri);
        [rq setPath:uri];
        [rq setBody:nil];
        [rq setMethod:@"GET"];
        [self setDebug:false];
        
        NSXMLDocument *metadoc = [self makeRequest:rq];
        
        /*find the Vidispine ID of the parent collection*/
        NSString *parentID = [self getParentID:metadoc];
        
        if(!parentID)
            continue;
        
        /*find the object pointer of the commission with the same Vidispine ID as the parent*/
        NSFetchRequest *commissionRequest = [NSFetchRequest fetchRequestWithEntityName:@"PLUTOCommission"];
        [commissionRequest setPredicate:[NSPredicate predicateWithFormat:@"vsid == %@",parentID]];
        NSArray *commissionResults = [moc executeFetchRequest:commissionRequest error:&error];
        
        NSLog(@"got %lu results for commissions matching %@",(unsigned long)[commissionResults count],parentID);
        
        for(NSManagedObject *commission in commissionResults){
            /*add the current project (in variable 'object') to the found commission*/
            NSMutableSet *existingChildren = [commission valueForKey:@"children"];
            [existingChildren addObject:object];
            [commission setValue:existingChildren forKey:@"children"];
        }
    }
    
    // Given some NSManagedObjectContext *context
/*    NSManagedObjectModel *model = [[moc persistentStoreCoordinator]
                                   managedObjectModel];
    for(NSEntityDescription *entity in [model entities]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        NSError *error;
        NSArray *results = [moc executeFetchRequest:request error:&error];
        // Error-checking here...
        for(NSManagedObject *object in results) {
            // Do your updates here
        }
    }*/
    
}
@end
