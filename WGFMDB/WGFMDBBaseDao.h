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
 *  子类根据@required、@optional可相应overwrite
 */
@protocol WGFMDBBaseDaoProtocol <NSObject>

@required
/**
 *  必须overwrite，设置相应的database，否则默认使用WGFMDBDataBase，代码中会引起程序奔溃
 */
- (void)setupDataBase;

@optional
/**
 *  一般不需要overwrite，如何修改特定的init初始化方法，则overwrite
 *
 *  @return 实例
 */
+ (instancetype)dao;

/**
 *  可以overwrite，database开库前做一些参数检测、配置
 *
 *  @return 开库成功失败
 */
- (BOOL)open;
/**
 *  此方法可以overwrite后，设置一个默认的WGFilePathModel路径
 *  或者通过调用setupFilePathModelWithType:FileInDirectory:FileName:方法动态设置
 */
- (void)setupFilePathModel;
@end


#pragma mark -
@interface WGFMDBBaseDao : NSObject<WGFMDBBaseDaoProtocol>
{
}

//MARK: 以下实例方法  一般不继承overwrite，需要overwrite的都归类在 WGFMDBBaseDaoProtocol所指定的方法中
- (void)closeAll;
- (void)removeDBFile;
- (void)closeAndRemoveDBFile;

- (void)setupDataBase:(id)dataBase;
- (void)setupFilePathModelWithType:(WGPathType)type
                   FileInDirectory:(NSString *)directory
                          FileName:(NSString *)fileName;

@property (nonatomic,readonly) WGFMDBDataBase *dataBase;
@property(nonatomic, readonly) FMDatabaseQueue *readOnlyQueue;
@property(nonatomic, readonly) FMDatabaseQueue *writableQueue;

@end
