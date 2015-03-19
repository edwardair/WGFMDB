//
//  WGBaseDao.h
//  Sqlit
//
//  Created by 丝瓜&冬瓜 on 15/3/19.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WGFMDBDataBase.h"

/**
 *  子类需引用此协议，并实现必要方法
 */
@protocol WGBaseDaoProtocol <NSObject>

@required
- (instancetype)initWithDataBase:(id )staticDataBase;

+ (BOOL)createTableInDatabase:(FMDatabase *)db;

@optional
+ (instancetype)dao;



@end


#pragma mark -
@interface WGBaseDao : NSObject
@property (nonatomic, readonly) WGFMDBDataBase *dataBase;

@property(nonatomic, readonly) FMDatabaseQueue *readOnlyQueue;
@property(nonatomic, readonly) FMDatabaseQueue *writableQueue;

@end
