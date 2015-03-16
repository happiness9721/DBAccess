//
//  DBTableInfo.h
//  DBAccess
//
//  Created by happiness9721 on 1/19/15.
//  Copyright (c) 2015 happiness9721. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBTableInfo : NSObject

@property(readonly) NSArray *fieldNames;
@property(readonly) NSArray *primaryKeys;

- (instancetype)initWithfieldNames:(NSArray *)fieldNames primaryKeys:(NSArray *)primaryKeys;

@end
