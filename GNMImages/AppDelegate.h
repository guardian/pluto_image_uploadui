//
//  AppDelegate.h
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AcornUtil.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet AcornUtil *acornUtil;
@property (assign) IBOutlet NSTreeController *treeController;
@property (assign) IBOutlet NSArrayController *selectedMasterArrayController;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)clearCachedObjects:(NSString *)entityDescription;

- (IBAction)saveAction:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)showPrefs:(id)sender;
- (IBAction)openMasterPage:(id)sender;

- (NSString *)currentAcornFilename;

- (NSString *)vspassword;
- (void)setVspassword:(NSString *)newPasswd;

- (NSString *)currentAcornFileURL;

@end
