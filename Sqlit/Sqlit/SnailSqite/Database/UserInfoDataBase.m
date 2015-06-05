//
//  UserInfoDataBase.m
//  Snail
//
//  Created by RayMi on 15/3/28.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "UserInfoDataBase.h"
#import "LocalUserInfoModel.h"
#import "Define.h"
#import <WGCategory/WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"

#define UserInfoTableName @"USERINFO_TABLE"

@implementation UserInfoDataBase
+ (instancetype)shared{
    static id defaultDataBase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDataBase = [[[self class] alloc]init];
    });
    return defaultDataBase;
}

#pragma mark - 必须重写的方法
- (NSString *)getTableName{
    return UserInfoTableName;
}
- (Protocol *)getModelBridgeToDBColumnProtocol{
    return @protocol(LocalUserInfoModelBridgeProtocol);
}
- (Class)getModelClass{
    return [LocalUserInfoModel class];
}


#pragma mark - SQL 语句
- (NSString *)sql_SelectUserInfoFromTable{
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",UserInfoTableName,WGPNAME(WGAuto_MOBILEPHONE)];
}
- (NSString *)sql_SelectLastLoginUserInfoFromTable{
    return [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC",UserInfoTableName,WGPNAME(WGAuto_LastLoginTimestamp)];
}
- (NSString *)sql_InsertLocalUserInfoIntoTable {
    return [NSString
            stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (?, ?, ?, ?, ?)",
            UserInfoTableName, [NSObject getColumnsWithBridgeProtocol:[self getModelBridgeToDBColumnProtocol]
                                                           ModelClass:[self getModelClass]
                                                               Except:nil
                                                       AppendWithType:NO]
            ];
}
- (NSString *)sql_UpdateLastLoginUserInfoIntoTable {
    return [NSString
            stringWithFormat:
            @"UPDATE %@ SET (%@, %@, %@, %@, %@, %@, %@, %@, "
            @"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, "
            @"?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) WHERE %@ = ?",
            UserInfoTableName, WGPNAME(WGAuto_PASSWORD), WGPNAME(WGAuto_IDKEY),
            WGPNAME(WGAuto_HEADPORTRAIT), WGPNAME(WGAuto_SCHOOL),
            WGPNAME(WGAuto_FULLNAME), WGPNAME(WGAuto_SEX), WGPNAME(WGAuto_AGE),
            WGPNAME(WGAuto_TYPES), WGPNAME(WGAuto_BALANCE),
            WGPNAME(WGAuto_MYINVITECODE),WGPNAME(WGAuto_STATES), WGPNAME(WGAuto_GRADE),
            WGPNAME(WGAuto_TEACHERSTYPES), WGPNAME(WGAuto_TEACHINGSUBJECTS),
            WGPNAME(WGAuto_INTRODUCTION), WGPNAME(WGAuto_LastLoginTimestamp),
            WGPNAME(WGAuto_LastLoginVersion), WGPNAME(WGAuto_IsLogin),WGPNAME(WGAuto_CITYS),
            WGPNAME(WGAuto_AUTHENTICATION),WGPNAME(WGAuto_IOSSTATES), WGPNAME(WGAuto_MOBILEPHONE)];
}


@end
