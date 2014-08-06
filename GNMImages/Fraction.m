//
//  Fraction.m
//  GNMImages
//
//  Created by localhome on 06/08/2014.
//  Copyright (c) 2014 Guardian News & Media. All rights reserved.
//

#import "Fraction.h"

// see http://stackoverflow.com/questions/10233890/convert-decimal-to-fraction-rational-number-in-objective-c

@implementation Fraction

- (id)init
{
    _num=0;
    _denom=0;
    _precisionLimit = [NSNumber numberWithDouble:0.001];
    return self;
}

- (void)reduce:(double)decimal
{
    double i = floor(decimal);
    double j = decimal - i;
    
    if(j < [_precisionLimit doubleValue]){
        _num = i;
        _denom = 1;
        return;// i/1;
    }
    [self reduce:(1/j)];
    
    NSInteger oldDenom=_denom;
    _denom = _num;
    _num = (i*_num)+oldDenom;

    
}

- (NSString *)stringValue
{
    return [self stringValue:@"/"];
}

- (NSString *)stringValue:(NSString *)separator
{
    NSString *rtn = [NSString stringWithFormat:@"%ld%@%ld",_num,separator,_denom];
    
    return rtn;
}

@end
