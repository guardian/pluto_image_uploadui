//
//  AppDelegate.m
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#include <objc/runtime.h>

#import "AppDelegate.h"
//#import "VidispineBase.h"
#import "VidispineCommissionGrabber.h"
#import "VidispineItemGrabber.h"
#import <AppleScriptObjC/AppleScriptObjC.h>

@interface AcornUtil : NSObject
- (void) test:(id)sender;

@end

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError *error;
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"GNMImages.storedata"];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
        
    // Insert code here to initialize your application
    NSManagedObjectContext *ctx=[self managedObjectContext];
    
    /*Class AcornUtilClass = [[NSBundle mainBundle] classNamed:@"AcornUtil"];
    id AcornUtil = class_createInstance(AcornUtilClass,0);*/
    Class AcornUtilClass = NSClassFromString(@"AcornUtil");
    
    AcornUtil *au = [[AcornUtilClass alloc] init];
    
    //id AcornUtil = [[NSClassFromString(@"AcornUtil") alloc] init];
    
    //id acorn = [[AcornUtil alloc] init];
 
    
/*    int i=0;
    unsigned int mc = 0;
    Method * mlist = class_copyMethodList(AcornUtil, &mc);
    NSLog(@"%d methods", mc);
    for(i=0;i<mc;i++)
        NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
 */
    
    [au test:self];
 
    
/*
 NSManagedObject *testCommissionOne = [NSEntityDescription insertNewObjectForEntityForName:@"PLUTOCommission"inManagedObjectContext:ctx];
    
    [testCommissionOne setValue:@"commission one" forKey:@"name"];
    
     NSManagedObject *testProjectOne = [NSEntityDescription insertNewObjectForEntityForName:@"PLUTOProject"inManagedObjectContext:ctx];
    [testProjectOne setValue:@"project one" forKey:@"name"];
    [testCommissionOne setValue:[NSSet setWithObject:testProjectOne] forKey:@"children"];
 */

    return;
    
    VidispineCommissionGrabber *grabber=[[VidispineCommissionGrabber alloc] init:@"dc1-mmlb-02.dc1.gnm.int" port:@"8080" username:@"admin" password:@"admin"];
    
    NSLog(@"getting commissions...");
    [grabber getCommissions:ctx];
    NSLog(@"getting projects...");
    [grabber getProjects:ctx];
    
    VidispineItemGrabber *ig=[[VidispineItemGrabber alloc] init:@"dc1-mmlb-02.dc1.gnm.int" port:@"8080" username:@"admin" password:@"admin"];
    [ig getMasters:ctx];
//    [grabber getMasters:ctx];
    
 NSLog(@"fixing up relations...");
//    [grabber fixupMasters:ctx];
    [grabber fixupProjects:ctx];
    
}


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "theguardian.com.GNMImages" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"theguardian.com.GNMImages"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GNMImages" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"GNMImages.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
     
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    return NSTerminateNow;
}

@end
