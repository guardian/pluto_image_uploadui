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
    
    //VSRequest *rq=[[VSRequest alloc] init:@"/collection" method:@"PUT" body:bodystring];
    VSRequest *rq=[[VSRequest alloc] init];
    [rq setPath:@"/collection"];
    [rq setBody:bodystring];
    [rq setMethod:@"PUT"];
    
    NSXMLDocument *returnedXML=[self makeRequest:rq];
    
    return 0;
}

@end
