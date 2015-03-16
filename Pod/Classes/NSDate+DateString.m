//
//  NSDate+DateString.m
//  DBAccess
//
//  Created by happiness9721 on 11/18/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "NSDate+DateString.h"

@implementation NSDate (DateString)

- (NSString *)dateString
{
    NSDateFormatter *formatter = [NSDateFormatter alloc];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:self];
}

@end
