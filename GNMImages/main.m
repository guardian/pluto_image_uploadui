//
//  main.m
//  GNMImages
//
//  Created by localhome on 04/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[])
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];

    return NSApplicationMain(argc, argv);
}
