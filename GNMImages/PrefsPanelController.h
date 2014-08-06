//
//  PrefsPanelController.h
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefsPanelController : NSWindowController

@property    IBOutlet NSWindow *panel;
@property    IBOutlet NSUserDefaultsController *sharedDefaultsController;


- (IBAction)closeClicked:(id)sender;
- (IBAction)open:(id)sender;

@end
