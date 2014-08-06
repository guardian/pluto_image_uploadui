//
//  PrefsPanelController.m
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "PrefsPanelController.h"

@interface PrefsPanelController ()

@end

@implementation PrefsPanelController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)closeClicked:(id)sender
{
    
}

- (void)open:(id)sender
{
 /*   [NSApp beginSheet:_panel completionHandler:^void(NSModalResponse responseCode){
        NSLog(@"sheet ended with %lu",(long)responseCode);
    }];
  */
 //   [NSApp beginSheet: panFilenameEditor modalForWindow: window modalDelegate: self didEndSelector: @selector(customSheetDidClose:returnCode:contextInfo:) contextInfo: nil];

    [NSApp beginSheet:_panel completionHandler:nil];
}
@end
