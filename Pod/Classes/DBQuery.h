//
//  DBQuery.h
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBResultSet.h"
#import "DBAccess.h"

@interface DBQuery : NSObject

- (instancetype)initWithClass:(Class)queryClass access:(DBAccess *)access;
- (DBQuery *)where:(NSString *)where;
- (DBQuery *)whereWithFormat:(NSString *)format, ...;
- (DBQuery *)limit:(NSUInteger)limit;
- (DBQuery *)offset:(NSUInteger)offset;
- (DBQuery *)orderBy:(NSString *)order;
- (DBQuery *)orderByDescending:(NSString *)order;
- (DBResultSet *)fetch;
- (id)firstObject;
- (NSDictionary *)groupBy:(NSString *)group;
- (NSInteger)count;
- (double)sumOf:(NSString *)columnName;

@end
