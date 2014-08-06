//
//  AcornUtil.h
// This header file defines the interface implemented in AcornUtil.applescript
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#ifndef GNMImages_AcornUtil_h
#define GNMImages_AcornUtil_h

@interface AcornUtil : NSObject
- (void) test:(id)sender;

- (NSString *)filename:(id)sender;
- (NSString *)currentFileURL:(id)sender;

- (NSNumber *)currentFileWidth:(id)sender;
- (NSNumber *)currentFileHeight:(id)sender;

@end



#endif
