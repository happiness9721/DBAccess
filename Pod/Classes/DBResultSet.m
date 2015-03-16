//
//  DBResultSet.m
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "DBResultSet.h"

@interface DBResultSet()
{
    NSArray *array;
}

@end

@implementation DBResultSet

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    self = [super init];
    array = [[NSArray alloc] initWithObjects:objects count:cnt];
    return self;
}

- (NSUInteger)count
{
    return [array count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [array objectAtIndex:index];
}

- (void)removeAll
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", _tableName];
    if (self.whereString)
    {
        sql = [sql stringByAppendingFormat:@" WHERE %@", _whereString];
    }
    [_dbAccess openDatabase];
    [_dbAccess finishStatement:[_dbAccess executeSQL:sql]];
    [_dbAccess closeDatabase];
}

@end
