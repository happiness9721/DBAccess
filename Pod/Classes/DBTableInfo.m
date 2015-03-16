//
//  DBTableInfo.m
//  DBAccess
//
//  Created by happiness9721 on 1/19/15.
//  Copyright (c) 2015 happiness9721. All rights reserved.
//

#import "DBTableInfo.h"

@implementation DBTableInfo

- (instancetype)initWithfieldNames:(NSArray *)fieldNames primaryKeys:(NSArray *)primaryKeys
{
    self = [super init];
    _fieldNames = fieldNames;
    _primaryKeys = primaryKeys;
    return self;
}

@end
