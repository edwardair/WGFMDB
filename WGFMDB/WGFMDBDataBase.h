//
//  WGFMDBDateBaseManager.h
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WGFilePathModel.h"
#import <FMDB/FMDB.h>

/**
 *  子类根据@required、@optional可相应overwrite
 */
@protocol WGFMDBDataBaseProtocol <NSObject>
@required
/**
 *  db文件不存在的情况下，创建数据库文件后，创建数据库表，
    子类必须继承并实现创建表功能
 */
- (BOOL)onCreateTable:(FMDatabaseQueue *)dbQueue;

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

@property (nonatomic,readonly) FMDatabaseQueue *readonlyQueue;
@property (nonatomic,readonly) FMDatabaseQueue *writeableQueue;

//MARK: 以下实例方法  一般不继承overwrite，需要overwrite的都归类在 WGFMDBBaseDaoProtocol所指定的方法中
/**
 *  本类子类一般使用单例模式，故留此通用初始化方法
        需要配置参数
 */
+ (instancetype)shared;

- (BOOL)open;
- (void)closeAll;
- (void)removeDBFile;
- (void)closeAndRemoveDBFile;


@end
