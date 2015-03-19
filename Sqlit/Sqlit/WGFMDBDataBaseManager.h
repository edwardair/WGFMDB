//
//  WGFMDBDateBaseManager.h
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WGFilePathModel.h"
#import "FMDB.h"

#pragma mark - 子类继承后，可以复写的方法
@protocol WGFMDBDataBaseManagerSubClass <NSObject>

@required
/**
 *  db文件不存在的情况下，创建数据库结构，
 子类可继承
 */
- (BOOL)onCreate:(FMDatabaseQueue *)db;
@optional
/**
 *  开库，子类可继承修改特定的配置
 */
- (FMDatabase *)getDB;

@end


#pragma mark -
/**
 *  数据库 文件控制管理
 */
@interface WGFMDBDataBaseManager : NSObject

@property (nonatomic,strong) WGFilePathModel *pathModel;

@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,readonly) FMDatabaseQueue *readonlyQueue;
@property (nonatomic,readonly) FMDatabaseQueue *writeableQueue;


/**
 *  db文件不存在的情况下，创建数据库结构，
    子类可继承
 */
- (BOOL)onCreate:(FMDatabaseQueue *)db;

- (BOOL)open;
- (void)closeAll;
- (void)closeAndRemoveDBFile;


@end
