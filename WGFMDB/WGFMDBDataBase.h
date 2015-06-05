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
#import "WGFMDBBridgeProtocol.h"
#import <objc/runtime.h>


/**
 *  子类根据@required、@optional可相应overwrite
 */
@protocol WGFMDBDataBaseProtocol <NSObject>
#pragma mark - 必须重写
@required
/**
 *  表名，子类必需重写
 */
- (NSString *)getTableName;
/**
 *  此Protocol方法名直接对应需要存入数据库表的column名
 当建表、插入整个model、更新整个model、获取整个model时，使用此Protocol定义的方法名来存取
 注意：方法名同时对应于项目中的各个model中的属性名，
 此Protocol仅作为哪些字段需要跟数据库来交互的一个桥接，不作为定义新属性使用
 */
- (Protocol *)getModelBridgeToDBColumnProtocol;
/**
 *  获取与数据库交互的数据模型，一般在model中引用 getModelBridgeToDBColumnProtocol的协议
 */
- (Class)getModelClass;

#pragma mark - 可视情况覆写
@optional
/**
 *  db文件不存在的情况下，创建数据库文件后，创建数据库表，
 子类可以继承并实现创建表功能
 */
- (BOOL)onCreateTable:(FMDatabaseQueue *)dbQueue;

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

#pragma mark - 以下实例方法一般不继承overwrite，需要overwrite的都归类在 WGFMDBBaseDaoProtocol所指定的方法中
/**
 *  本类子类一般使用单例模式，故留此通用初始化方法
        需要配置参数
 */
+ (instancetype)shared;

/**
 *  检测表的column是否都存在，不存在的，需要添加
 */
- (void)checkTableColumnIfExist;

- (BOOL)open;
- (void)closeAll;
- (void)removeDBFile;
- (void)closeAndRemoveDBFile;


@end