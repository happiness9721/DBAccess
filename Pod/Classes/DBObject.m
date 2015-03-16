//
//  DBObject.m
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "DBObject.h"
#import <objc/runtime.h>

@implementation DBObject

- (instancetype)init
{
    self = [super init];
    return self;
}

- (BOOL)commit
{
    BOOL success = YES;
    DBAccess *access = [[DBAccess alloc] initWithDbFileNamed:[self.class getDbFileName]];
    [access openDatabase];
    DBTableInfo *tableInfo = [self.class getTableInfo];
    if (![self insertOrIgnoreWithTableInfo:tableInfo access:access])
    {
        success = NO;
    }
    if (![self updateObjectWithTableInfo:tableInfo access:access])
    {
        success = NO;
    }
    [access closeDatabase];
    return success;
}

- (BOOL)remove
{
    BOOL success = NO;
    DBAccess *access = [[DBAccess alloc] initWithDbFileNamed:[self.class getDbFileName]];
    DBTableInfo *tableInfo = [self.class getTableInfo];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE", NSStringFromClass([self class])];
    for (NSString *primaryKey in tableInfo.primaryKeys)
    {
        sql = [sql stringByAppendingFormat:@"%@ = '%@'", primaryKey, [self valueForKey:primaryKey]];
    }
    
    [access openDatabase];
    success = [access finishStatement:[access executeSQL:sql]];
    [access closeDatabase];
    return success;
}

+ (BOOL)commitArray:(NSArray *)array
{
    BOOL success = YES;
    DBAccess *access = [[DBAccess alloc] initWithDbFileNamed:[self.class getDbFileName]];
    [access openDatabase];
    DBTableInfo *tableInfo = [self.class getTableInfo];
    for (DBObject *object in array)
    {
        if (![object insertOrIgnoreWithTableInfo:tableInfo access:access])
        {
            success = NO;
        }
        if (![object updateObjectWithTableInfo:tableInfo access:access])
        {
            success = NO;
        }
    }
    [access closeDatabase];
    return success;
}

+ (NSString *)getDbFileName
{
    [NSException raise:@"Invoked abstract method" format:@"Invoked abstract method"];
    return nil;
}

+ (DBQuery *)query
{
    DBAccess *access = [[DBAccess alloc] initWithDbFileNamed:[self.class getDbFileName]];
    DBQuery *query = [[DBQuery alloc] initWithClass:[self class] access:access];
    return query;
}

- (BOOL)insertOrIgnoreWithTableInfo:(DBTableInfo *)tableInfo access:(DBAccess *)access
{
    BOOL success = NO;
    NSString *sql;
    NSString *sqlValue;
    NSMutableArray *valueArray = [NSMutableArray new];
    for (NSString *fieldName in tableInfo.fieldNames)
    {
        id value = [self valueForKey:fieldName];
        if (value)
        {
            if (!sql)
            {
                sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@ (%@", NSStringFromClass([self class]), fieldName];
                sqlValue = @"VALUES (?";
                [valueArray addObject:value];
            }
            else
            {
                sql = [sql stringByAppendingFormat:@", %@", fieldName];
                sqlValue = [sqlValue stringByAppendingString:@", ?"];
                [valueArray addObject:value];
            }
        }
    }
    if (sql)
    {
        sql = [sql stringByAppendingFormat:@")%@)", sqlValue];
        sqlite3_stmt *stmt = [access executeSQL:sql];
        //for (id value in valueArray)
        for (int index = 0; index < valueArray.count; index++)
        {
            id value = [valueArray objectAtIndex:index];
            if ([value isKindOfClass:[NSString class]])
            {
                sqlite3_bind_text(stmt, index + 1, [value UTF8String], -1,  SQLITE_TRANSIENT);
            }
            else
            {
                sqlite3_bind_double(stmt, index + 1, [value doubleValue]);
            }
        }
        int sqliteState = sqlite3_step(stmt);
        if (sqliteState != SQLITE_DONE)
        {
            NSLog(@"%@ : Insert Failed. Code = %d", NSStringFromClass(self.class), sqliteState);
        }
        success = [access finishStatement:stmt];
    }
    return success;
}

- (BOOL)updateObjectWithTableInfo:(DBTableInfo *)tableInfo access:(DBAccess *)access
{
    BOOL success = NO;
    NSString *sql;
    NSMutableArray *valueArray = [NSMutableArray new];
    for (NSString *fieldName in tableInfo.fieldNames)
    {
        id value = [self valueForKey:fieldName];
        if (value)
        {
            if (!sql)
            {
                sql = [NSString stringWithFormat:@"UPDATE %@ Set %@ = ?", NSStringFromClass([self class]), fieldName];
                [valueArray addObject:value];
            }
            else
            {
                sql = [sql stringByAppendingFormat:@", %@ = ?", fieldName];
                [valueArray addObject:value];
            }
        }
    }
    if (sql)
    {
        NSString *whereString;
        for (NSString *primaryKey in tableInfo.primaryKeys)
        {
            id value = [self valueForKey:primaryKey];
            if (value)
            {
                if (!whereString)
                {
                    whereString = [NSString stringWithFormat:@" WHERE %@ = ?", primaryKey];
                    [valueArray addObject:value];
                }
                else
                {
                    whereString = [whereString stringByAppendingFormat:@" AND %@ = ?", primaryKey];
                    [valueArray addObject:value];
                }
            }
        }
        if (whereString)
        {
            sql = [sql stringByAppendingString:whereString];
            sqlite3_stmt *stmt = [access executeSQL:sql];
            //for (id value in valueArray)
            for (int index = 0; index < valueArray.count; index++)
            {
                id value = [valueArray objectAtIndex:index];
                if ([value isKindOfClass:[NSString class]])
                {
                    sqlite3_bind_text(stmt, index + 1, [value UTF8String], -1,  SQLITE_TRANSIENT);
                }
                else
                {
                    sqlite3_bind_double(stmt, index + 1, [value doubleValue]);
                }
            }
            int sqliteState = sqlite3_step(stmt);
            if (sqliteState != SQLITE_DONE)
            {
                NSLog(@"%@ : Update Failed. Code = %d", NSStringFromClass(self.class), sqliteState);
            }
            success = [access finishStatement:stmt];
        }
    }
    return success;
}

+ (DBTableInfo *)getTableInfo
{
    DBAccess *access = [[DBAccess alloc] initWithDbFileNamed:[self.class getDbFileName]];
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", NSStringFromClass(self.class)];
    NSMutableArray *fieldNames = [NSMutableArray new];
    NSMutableArray *primaryKeys = [NSMutableArray new];
    [access openDatabase];
    sqlite3_stmt *statement = [access executeSQL:sql];
    while(sqlite3_step(statement) == SQLITE_ROW)
    {
        NSInteger count = sqlite3_column_count(statement);
        NSString *columnValue;
        BOOL isPramaryKey = NO;
        for (int index = 0; index < count; index++)
        {
            NSString *columnName = [NSString stringWithCString:sqlite3_column_name(statement, index) encoding:NSUTF8StringEncoding];
            if ([columnName isEqualToString:@"name"])
            {
                columnValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, index)];
            }
            if ([columnName isEqualToString:@"pk"])
            {
                if (sqlite3_column_int(statement, index))
                {
                    isPramaryKey = YES;
                }
            }
        }
        [fieldNames addObject:columnValue];
        if (isPramaryKey)
        {
            [primaryKeys addObject:columnValue];
        }
    }
    [access finishStatement:statement];
    [access closeDatabase];
    return [[DBTableInfo alloc] initWithfieldNames:fieldNames primaryKeys:primaryKeys];
}

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
//{
//    NSString *sel = NSStringFromSelector(selector);
//    if ([sel rangeOfString:@"set"].location == 0)
//    {
//        return [NSMethodSignature signatureWithObjCTypes:"v@:@:"];
//    } else {
//        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
//    }
//}
//
//- (void)forwardInvocation:(NSInvocation *)invocation
//{
//    NSString *key = NSStringFromSelector([invocation selector]);
//    if ([key rangeOfString:@"set"].location == 0)
//    {
//        key = [[key substringWithRange:NSMakeRange(3, [key length]-4)] lowercaseString];
//        NSString *obj;
//        NSString *keyValue;
//        [invocation getArgument:&keyValue atIndex:3];
//        [invocation getArgument:&obj atIndex:2];
//        [data setObject:obj forKey:keyValue];
//    }
//    else
//    {
//        NSString *obj = [data objectForKey:key];
//        [invocation setReturnValue:&obj];
//    }
//}

@end
