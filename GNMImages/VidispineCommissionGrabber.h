//
//  VidispineCommissionGrabber.h
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VidispineBase.h"

@interface VidispineCommissionGrabber : VidispineBase

-(int)getGeneric:(NSString *)type entityName:(NSString *)entityName bodyString:(NSString *)bodyString managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (int)getCommissions:managedObjectContext;
- (int)getProjects:managedObjectContext;
- (int)getMasters:managedObjectContext;

- (void)fixupProjects:managedObjectContext;
- (void)fixupMasters:(NSManagedObjectContext *)moc;

- (void)processVidispineXML:(NSXMLDocument *)xmlDoc type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc;

- (void)processVidispineElement:(NSXMLElement *)element type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc;
@end
