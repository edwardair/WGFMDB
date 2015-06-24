//
//  UserInfoDao.m
//  Snail
//
//  Created by 丝瓜&冬瓜 on 15/4/3.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "UserInfoDao.h"
#import "UserInfoDataBase.h"
#import "Define.h"
#import <WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"

@implementation UserInfoDao
#pragma mark - 继承父类重写的方法
+ (instancetype)dao{
    static id dao;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dao = [[[self class]alloc]init];
    });
    
    return dao;
}

- (void)setupDataBase{
    [super setupDataBase:[UserInfoDataBase shared]];
}
- (void)setupFilePathModel{
    /**
     *  用户表是存储在公共区域的
     */
    [super setupFilePathModelWithType:kWGPathTypeDocuments
                      FileInDirectory:[SnailDirectory stringByAppendingPathComponent:PublicUserInfoDirectory]
                             FileName:PublicUserInfoDBName];
}

#pragma mark - db create
- (BOOL)openWithUserMobile:(NSString *)userMobile{
    //动态修改 dataBase路径
    if (userMobile.length==0) {
        WGLogError(@"userMobile不能为空，开库失败!");
        return NO;
    }
    return [super open];
}

#pragma mark - db select

- (LocalUserInfoModel *)userInfoWithMobile:(NSString *)userMobile{
    __block LocalUserInfoModel *userInfoModel = nil;
    WEAKSELF
    
    NSString *sql = [(UserInfoDataBase *)weakSelf.dataBase sql_SelectUserInfoFromTable];

    [self.readOnlyQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql, userMobile];
        if ([rs next]) {
            userInfoModel = [LocalUserInfoModel modelWithResultSet:rs];
        }
        [rs close];
    }];
    
    return userInfoModel;
}
- (LocalUserInfoModel *)lastLoginUserInfo{
   
    WEAKSELF
    
    __block LocalUserInfoModel *localUserInfoModel = nil;
    
    NSString *sql = [(UserInfoDataBase *)weakSelf.dataBase sql_SelectLastLoginUserInfoFromTable];
    
    [self.readOnlyQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next]) {
            localUserInfoModel = [LocalUserInfoModel modelWithResultSet:rs];
        }
        [rs close];
    }];
    
    return localUserInfoModel;
}

#pragma mark - db update or insert
- (NSArray *)arguments:(NSArray *)columnModels Resource:(LocalUserInfoModel *)model{
    NSMutableArray *tmp = @[].mutableCopy;
    
    for (WGFMDBColumnModel *m in columnModels) {
        [tmp addObject:[NSString handleNetString:WGMODEL_VALUE(model, m.columnName)]];
    }
    
    return tmp;
    
}
- (BOOL)asyncInsertLocalUserInfo:(LocalUserInfoModel *)localUserInfoModel{
    WEAKSELF
    
    __block BOOL flag = NO;
    
    NSArray *columnModels =
    [WGFMDBColumnModel getColumnsWithBridgeProtocol:
     [self.dataBase getModelBridgeToDBColumnProtocol]
                                             Except:nil];
    
    if (columnModels.count==0) {
        WGLogError(@"插入LocalUserInfoModel时，获取不到BridgeProtocol中的属性名字段");
        return NO;
    }
    
    NSString *sql = [(UserInfoDataBase *)weakSelf.dataBase
                     sql_InsertLocalUserInfoIntoTableWithColumns:columnModels];
    [self.writableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql withParameterDictionary:localUserInfoModel.modelValue
                ];

        if (!flag) {
            WGLogError(@"LocalUserInfoModel 插入、替换失败!");
        }
        
    }];
    
    return flag;
}




@end
