//
//  DBAccess.m
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import "DBAccess.h"

@interface DBAccess()
{
    sqlite3 *_database;
    NSString *_dbFileName;
}

@end

@implementation DBAccess

- (instancetype)initWithDbFileNamed:(NSString *)dbFileName;
{
    self = [super init];
    _dbFileName = dbFileName;
    return self;
}

- (void)openDatabase
{
    @synchronized(self)
    {
        NSString *dbPath = [self getDBPath];
//        NSLog(@"%@", dbPath);
        if (_database)
        {
            [self closeDatabase];
        }
        [self copyDatabaseIfNeeded];
        int result = sqlite3_open([dbPath UTF8String], &_database);
        if (result != SQLITE_OK)
        {
            _database = nil;
            NSAssert(0,@"Failed to open database");
        }
    }
}

- (void)closeDatabase
{
    @synchronized(self)
    {
        if (_database)
        {
            sqlite3_stmt * stmt;
            while ((stmt = sqlite3_next_stmt(_database, NULL)) != NULL)
            {
                sqlite3_finalize(stmt);
            }
            sqlite3_close(_database);
            _database = nil;
        }
    }
}

- (NSString *)getDBPath
{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:_dbFileName];
}

- (void)deleteDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if (success)
    {
        success = [fileManager removeItemAtPath:dbPath error:&error];
        if (!success)
            NSAssert1(0, @"Failed to delete database file with message '%@'.", [error localizedDescription]);
    }
}

- (void)copyDatabaseIfNeeded
{
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success)
    {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_dbFileName];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (sqlite3_stmt *)executeSQL:(NSString *)sql
{
    sqlite3_stmt *statement;
    @synchronized(self)
    {
        if (_database)
        {
            int success = sqlite3_prepare_v2(_database, sql.UTF8String, -1, &statement, NULL);
            if (success != SQLITE_OK)
            {
                NSLog(@"Error: failed to execute SQL. Code = %d", success);
            }
        }
        else
        {
            NSLog(@"Error: database not initialize.");
        }
    }
    
    return statement;
}

- (NSInteger)finishStatement:(sqlite3_stmt *)stmt
{
    int success = NO;
    stmt = sqlite3_next_stmt(_database, NULL);
    while (stmt)
    {
        sqlite3_step(stmt);
        success = sqlite3_finalize(stmt);
        stmt = sqlite3_next_stmt(_database, NULL);
    }
    return success;
}

@end
