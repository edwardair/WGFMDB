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
#import <WGCategory/WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"

@implementation UserInfoDao
+ (instancetype)dao{
    static id dao;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dao = [[[self class]alloc]init];
    });
    
    return dao;
}

#pragma mark - 设置默认的database
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
- (BOOL)asyncUpdateLocalUserInfo:(LocalUserInfoModel *)localUserInfoModel {
    return [self asyncInsertLocalUserInfo:localUserInfoModel];
    //TODO: UPDATE 有语法错误
//    WEAKSELF
//    
//    __block BOOL flag = NO;
//    
//    NSString *sql = [(UserInfoDataBase *)
//                     weakSelf.dataBase sql_UpdateLastLoginUserInfoIntoTable];
//    
//    [self.writableQueue inDatabase:^(FMDatabase *db) {
//        flag = [db executeUpdate:sql,
//                localUserInfoModel.WGAuto_PASSWORD,
//                localUserInfoModel.WGAuto_IDKEY,
//                localUserInfoModel.WGAuto_HEADPORTRAIT,
//                localUserInfoModel.WGAuto_SCHOOL,
//                localUserInfoModel.WGAuto_FULLNAME,
//                localUserInfoModel.WGAuto_SEX,
//                localUserInfoModel.WGAuto_AGE,
//                localUserInfoModel.WGAuto_TYPES,
//                localUserInfoModel.WGAuto_BALANCE,
//                localUserInfoModel.WGAuto_INVITECODE,
//                localUserInfoModel.WGAuto_GRADE,
//                localUserInfoModel.WGAuto_TEACHERSTYPES,
//                localUserInfoModel.WGAuto_TEACHINGSUBJECTS,
//                localUserInfoModel.WGAuto_INTRODUCTION,
//                localUserInfoModel.WGAuto_LastLoginTimestamp,
//                [NSNumber numberWithDouble:localUserInfoModel.WGAuto_LastLoginTimestamp],
//                localUserInfoModel.WGAuto_MOBILEPHONE];
//        
//        if (!flag) {
//            WGLogError(@"LocalUserInfoModel 更新失败!");
//        }
//        
//    }];
//    
//    return flag;
}

- (BOOL)asyncInsertLocalUserInfo:(LocalUserInfoModel *)localUserInfoModel{
    
    WEAKSELF
    
    __block BOOL flag = NO;
    
    NSString *sql = [(UserInfoDataBase *)
                     weakSelf.dataBase sql_InsertLocalUserInfoIntoTable];
    
    [self.writableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql,
                localUserInfoModel.WGAuto_MOBILEPHONE,
                localUserInfoModel.WGAuto_PASSWORD,
                localUserInfoModel.WGAuto_IDKEY,
                localUserInfoModel.WGAuto_HEADPORTRAIT,
//                localUserInfoModel.WGAuto_SCHOOL,
                localUserInfoModel.WGAuto_FULLNAME
//                localUserInfoModel.WGAuto_SEX,
//                localUserInfoModel.WGAuto_AGE,
//                localUserInfoModel.WGAuto_TYPES,
//                localUserInfoModel.WGAuto_BALANCE,
//                localUserInfoModel.WGAuto_MYINVITECODE,
//                localUserInfoModel.WGAuto_STATES,
//                localUserInfoModel.WGAuto_GRADE,
//                localUserInfoModel.WGAuto_TEACHERSTYPES,
//                localUserInfoModel.WGAuto_TEACHINGSUBJECTS,
//                localUserInfoModel.WGAuto_INTRODUCTION,
//                [NSNumber numberWithDouble:localUserInfoModel.WGAuto_LastLoginTimestamp],
//                localUserInfoModel.WGAuto_LastLoginVersion,
//                @(localUserInfoModel.WGAuto_IsLogin),
//                localUserInfoModel.WGAuto_CITYS,
//                localUserInfoModel.WGAuto_AUTHENTICATION,
//                localUserInfoModel.WGAuto_IOSSTATES
                ];
        
        if (!flag) {
            WGLogError(@"LocalUserInfoModel 插入、替换失败!");
        }
        
    }];
    
    return flag;
}

#pragma mark - db 转 model

#pragma mark - model 转 db


@end
