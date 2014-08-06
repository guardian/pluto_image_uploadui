//
//  VidispineItemGrabber.h
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "VidispineBase.h"

@interface VidispineItemGrabber : VidispineBase

- (void)fixupMasters:(NSManagedObjectContext *)moc;
- (int)getMasters:managedObjectContext;
- (void)processVidispineXML:(NSXMLDocument *)xmlDoc type:(NSString *)type entityName:(NSString *)entityName managedObjectContext:(NSManagedObjectContext *)moc;

- (NSManagedObject *) findProjectByID:(NSString *)vsid managedObjectContext:(NSManagedObjectContext *)moc;
@end
