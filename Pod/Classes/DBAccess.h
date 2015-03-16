//
//  DBAccess.h
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBAccess : NSObject

- (instancetype)initWithDbFileNamed:(NSString *)dbFileName;
- (void)openDatabase;
- (void)closeDatabase;
- (void)deleteDatabase;
- (void)copyDatabaseIfNeeded;
- (sqlite3_stmt *)executeSQL:(NSString *)sql;
- (NSInteger)finishStatement:(sqlite3_stmt *)stmt;

@end
