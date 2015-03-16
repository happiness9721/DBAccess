//
//  DBResultSet.h
//  DBAccess
//
//  Created by happiness9721 on 9/25/14.
//  Copyright (c) 2014 happiness9721. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBAccess.h"

@interface DBResultSet : NSArray

@property NSString *tableName;
@property DBAccess *dbAccess;
@property NSString *whereString;

- (void)removeAll;

@end
