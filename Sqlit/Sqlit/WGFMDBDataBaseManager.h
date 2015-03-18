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
/**
 *  数据库 文件控制管理
 */
@interface WGFMDBDataBaseManager : NSObject

@property (nonatomic,strong) WGFilePathModel *pathModel;

@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,readonly) FMDatabaseQueue *readonlyQueue;
@property (nonatomic,readonly) FMDatabaseQueue *writeableQueue;


- (BOOL)open;
- (void)closeAll;
- (void)closeAndRemoveDBFile;

@end
