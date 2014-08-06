//
//  Fraction.h
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fraction : NSObject
@property NSInteger num;
@property NSInteger denom;
@property NSNumber *precisionLimit;

- (id)init;
- (void)reduce:(double)decimal;
- (NSString *)stringValue;
- (NSString *)stringValue:(NSString *)separator;

@end
