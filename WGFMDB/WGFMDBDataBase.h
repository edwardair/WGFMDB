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
#import "WGFMDBBridgeProtocol.h"
#import "NSObject+WGSQLModelHelper.h"


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
 
 ** 协议中定义的字段，必须是以@property定义的属性
    eg: @property (nonatomic,copy) NSString *WGAuto_MOBILEPHONE;
 */
- (Protocol *)getModelBridgeToDBColumnProtocol;

#pragma mark - 可视情况覆写
@optional
/**
 *  db文件不存在的情况下，创建数据库文件后，创建数据库表
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
- (void)appendTableColumnIfNotExist;

/**
 *  根据给定的数组，生成建表、插入、更新表的column组合字符串
 *
 *  @param colmunModels @[WGFMDBColumnModel]
 *  @param hasType      column名后是否附带数据库类型
 *
 *  @return @"WGAuto_USERMOBILE TEXT,WGAuto_LOGIN BIT,..."
 */
- (NSString *)columnNames:(NSArray *)colmunModels appendColumnType:(BOOL)hasType;

- (BOOL)open;
- (void)closeAll;
- (void)removeDBFile;
- (void)closeAndRemoveDBFile;


@end
