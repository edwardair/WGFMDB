
//
//  WGEasyManager.m
//  Sqlit
//
//  Created by RayMi on 15/6/25.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGEasyManager.h"
#import "WGFMDBDataBase.h"

@interface WGEasyManager : NSObject

#define DATABASE(dbBase,filepath) @{@"database":dbBase,@"filepath":filepath}
#define dbBase(database) database[@"database"]
#define filePath(database) database[@"filepath"]

/**
 *  @{className:DATABASE}
 */
@property (nonatomic,strong) NSMutableDictionary *DBs;
@end
@implementation WGEasyManager
+ (instancetype)shared{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}
- (id )init{
    if (self=[super init]) {
        _DBs = @{}.mutableCopy;
    }
    return self;
}

#pragma mark -
- (BOOL)registerTable:(Class )class AtPath:(WGFilePathModel *(^)())pathModelBlock{
    @synchronized(self){
        WGFilePathModel *pathModel = pathModelBlock();
        if (!pathModel) {
            pathModel = [WGFilePathModel modelWithType:kWGPathTypeTmp FileInDirectory:nil];
        }
        
        BOOL isClassRegisted = NO;
        WGFilePathModel *existPathModel;
        WGFMDBDataBase *existDbBase;
        if ([_DBs.allKeys containsObject:NSStringFromClass(class)]) {
            NSDictionary *dataBase = _DBs[NSStringFromClass(class)];
            existPathModel = filePath(dataBase);
            existDbBase = dbBase(dataBase);
            isClassRegisted = YES;
        }
        
        //class已注册过
        if (isClassRegisted) {
            //检测路径是否相同，相同的则忽略开库
            if ([existDbBase.pathModel.fullPath isEqualToString:pathModel.fullPath]) {
                //路径相同，不需要重复开库
                //同时class也注册过，不需要重复检测table是否创建，表字段是否已增加
                return YES;
            }else{
                //路径不同，需要先注销当前的
                [self resignTable:class];
                //开库
                WGFMDBDataBase *newDataBase = [[WGFMDBDataBase alloc]init];
                newDataBase.pathModel = pathModel;
                BOOL success = [newDataBase open];
                if (success) {
                    //成功，继续检测table
                    
                }
            }
        }else{
            //开库
        }
        
        
        return YES;
    }
}
- (BOOL)resignTable:(Class )class{
    return YES;
}

@end


@implementation NSObject(WGEasyManager)

@end
