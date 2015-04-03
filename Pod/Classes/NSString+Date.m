//
//  NSString+Date.m
//  DBAccess
//
//  Created by happiness9721 on 11/19/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

- (NSDate *)dateFromString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:self];
}

- (NSString *)dateString
{
    NSString *dateString = [[self componentsSeparatedByString:@" "] firstObject];
    return dateString;
}

@end
