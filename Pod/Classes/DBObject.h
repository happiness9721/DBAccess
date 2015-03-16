//
//  DBObject.h
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBQuery.h"
#import "NSDate+DateString.h"
#import "NSString+Date.h"
#import "DBTableInfo.h"

@interface DBObject : NSObject

- (BOOL)commit;
- (BOOL)remove;
+ (BOOL)commitArray:(NSArray *)array;
+ (DBQuery *)query;
+ (NSString *)getDbFileName;
+ (DBTableInfo *)getTableInfo;

@end

