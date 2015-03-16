//
//  DBQuery.m
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "DBQuery.h"
#import <objc/runtime.h>

@interface DBQuery()
{
    DBAccess *_dbAccess;
    NSString *_whereString;
    NSString *_orderString;
    NSUInteger _limitValue;
    NSUInteger _offsetValue;
    Class _queryClassValue;
}

@end

@implementation DBQuery

- (instancetype)initWithClass:(Class)queryClass access:(DBAccess *)access
{
    self = [super init];
    _queryClassValue = queryClass;
    _dbAccess = access;
    return self;
}

- (DBQuery *)where:(NSString *)where
{
    _whereString = where;
    return self;
}

- (DBQuery *)whereWithFormat:(NSString *)format, ...
{
    va_list va;
    va_start(va, format);
    if ([format rangeOfString:@"like" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        format = [format stringByReplacingOccurrencesOfString:@"%@" withString:@"'%@'"];
    }
    NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
    va_end(va);
    _whereString = string;
    return self;
}

- (DBQuery *)orderBy:(NSString *)order
{
    _orderString = [NSString stringWithFormat:@"%@", order];
    return self;
}

- (DBQuery *)orderByDescending:(NSString *)order
{
    _orderString = [NSString stringWithFormat:@"%@ DESC", order];
    return self;
}

- (DBQuery *)limit:(NSUInteger)limit
{
    _limitValue = limit;
    return self;
}

- (DBQuery *)offset:(NSUInteger)offset
{
    _offsetValue = offset;
    return self;
}

- (NSString *)sqlString
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", NSStringFromClass(_queryClassValue)];
    if (_whereString)
    {
        sql = [sql stringByAppendingFormat:@" WHERE %@", _whereString];
    }
    if (_orderString)
    {
        sql = [sql stringByAppendingFormat:@" ORDER BY %@", _orderString];
    }
    if (_limitValue)
    {
        sql = [sql stringByAppendingFormat:@" LIMIT %ld", (unsigned long)_limitValue];
    }
    if (_offsetValue)
    {
        sql = [sql stringByAppendingFormat:@" OFFSET %ld", (unsigned long)_offsetValue];
    }
    return sql;
}

- (NSDictionary *)groupBy:(NSString *)group
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSString *sql = [self sqlString];
    [_dbAccess openDatabase];
    sqlite3_stmt *statement = [_dbAccess executeSQL:sql];
    
    while(sqlite3_step(statement) == SQLITE_ROW)
    {
        id newObject = [_queryClassValue alloc];
        NSInteger count = sqlite3_column_count(statement);
        for (int index = 0; index < count; index++)
        {
            NSString *columnValue = sqlite3_column_text(statement, index) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, index)] : nil;
            if (columnValue)
            {
                NSString *columnName = [NSString stringWithCString:sqlite3_column_name(statement, index) encoding:NSUTF8StringEncoding];
                [newObject setValue:columnValue forKey:columnName];
            }
        }
        NSString *groupName = [newObject valueForKey:group];
        NSMutableArray *dataSet = [dictionary objectForKey:groupName];
        if (!dataSet)
        {
            [dictionary setObject:[[NSMutableArray alloc] initWithObjects:newObject, nil] forKey:groupName];
        }
        else
        {
            [dataSet addObject:newObject];
        }
    }
    [_dbAccess finishStatement:statement];
    [_dbAccess closeDatabase];
    return dictionary;
}

- (DBResultSet *)fetch
{
    NSString *sql = [self sqlString];
    NSMutableArray *dataSet = [[NSMutableArray alloc] init];
    [_dbAccess openDatabase];
    sqlite3_stmt *statement = [_dbAccess executeSQL:sql];

    while(sqlite3_step(statement) == SQLITE_ROW)
    {
        id newObject = [_queryClassValue alloc];
        NSInteger count = sqlite3_column_count(statement);
        for (int index = 0; index < count; index++)
        {
            NSString *columnValue = sqlite3_column_text(statement, index) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, index)] : nil;
            if (columnValue)
            {
                NSString *columnName = [NSString stringWithCString:sqlite3_column_name(statement, index) encoding:NSUTF8StringEncoding];
                [newObject setValue:columnValue forKey:columnName];
            }
        }
        [dataSet addObject:newObject];
    }
    [_dbAccess finishStatement:statement];
    [_dbAccess closeDatabase];
    DBResultSet *resultSet = [[DBResultSet alloc] initWithArray:dataSet];
    resultSet.dbAccess = _dbAccess;
    resultSet.tableName = NSStringFromClass(_queryClassValue);
    resultSet.whereString = _whereString;
    return resultSet;
}

- (id)firstObject
{
    return [[[self limit:1] fetch] firstObject];
}

- (NSInteger)count
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", NSStringFromClass(_queryClassValue)];
    [_dbAccess openDatabase];
    sqlite3_stmt *statement = [_dbAccess executeSQL:sql];
    NSInteger count = 0;
    
    while(sqlite3_step(statement) == SQLITE_ROW)
    {
        count = sqlite3_column_int(statement, 0);
    }
    [_dbAccess finishStatement:statement];
    [_dbAccess closeDatabase];
    return count;
}

- (double)sumOf:(NSString *)columnName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@",columnName ,NSStringFromClass(_queryClassValue)];
    [_dbAccess openDatabase];
    sqlite3_stmt *statement = [_dbAccess executeSQL:sql];
    double sum = 0;
    
    while(sqlite3_step(statement) == SQLITE_ROW)
    {
        sum = sqlite3_column_int(statement, 0);
    }
    [_dbAccess finishStatement:statement];
    [_dbAccess closeDatabase];
    return sum;
}

@end
