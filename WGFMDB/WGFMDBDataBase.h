//
//  WGFMDBDateBaseManager.h
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import <FMDB/FMDB.h>

#import "WGFilePathModel.h"
#import "WGFMDBColumnModel.h"
#import "NSObject+WGSQLModelHelper.h"


/**
 *  子类根据@required、@optional可相应overwrite
 */
@protocol WGFMDBDataBaseProtocol <NSObject>
#pragma mark - 可视情况覆写
@optional
/**
 *  开库，子类可继承修改特定的配置，一般不需要overwrite
 */
- (FMDatabase *)getDB;
@end


#pragma mark -
/**
 *  数据库 文件控制管理，默认存储在Cacha文件夹下
 */
@interface WGFMDBDataBase : NSObject<WGFMDBDataBaseProtocol>

@property (nonatomic,strong) WGFilePathModel *pathModel;

@property(nonatomic, strong, readonly) FMDatabaseQueue *writeableQueue;
@property(nonatomic, strong, readonly) FMDatabaseQueue *readonlyQueue;

#pragma mark - 以下实例方法一般不继承overwrite，需要overwrite的都归类在 WGFMDBBaseDaoProtocol所指定的方法中

/**
 *  建表，如果表存在，不重复创建
 *
 *  @param tableName 表名
 *
 *  @return 成功、失败
 */
- (BOOL)createTable:(Class )tableClass;
/**
 *  检测表的column是否都存在，不存在的，需要添加
 */
- (BOOL )appendTableColumnIfNotExistWithOwnClass:(Class )ownClass InDataBase:(FMDatabase *)db;


- (BOOL)open;
- (void)closeAll;
- (void)removeDBFile;
- (void)closeAndRemoveDBFile;



@end
