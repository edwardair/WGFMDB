////
////  UserInfoDataBase.m
////  Snail
////
////  Created by RayMi on 15/3/28.
////  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
////
//
//#import "UserInfoDataBase.h"
//#import "LocalUserInfoModel.h"
//#import "Define.h"
//#import <WGDefines.h>
//
//#define UserInfoTableName @"USERINFO_TABLE"
//
//@implementation UserInfoDataBase
//#pragma mark - 需继承父类重写的方法
//+ (instancetype)shared{
//    static id defaultDataBase;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        defaultDataBase = [[[self class] alloc]init];
//    });
//    return defaultDataBase;
//}
//- (NSString *)getTableName{
//    return UserInfoTableName;
//}
//- (Protocol *)getModelBridgeToDBColumnProtocol{
//    return @protocol(LocalUserInfoModelBridgeProtocol);
//}
//
//
//#pragma mark - SQL 语句
///**
// *  根据数组，返回对应的 ":WGAuto_USER_ID,:WGAuto_MOBILE"字符串
// */
//- (NSString *)placeHolderWithArray:(NSArray *)array{
//    NSMutableString *placeHolder = [NSMutableString string];
//    for (int i = 0; i < array.count; i++) {
//        [placeHolder appendFormat:@"%@,",[array[i] placeHolder]];
//    }
//    
//    if ([placeHolder hasSuffix:@","]) {
//        [placeHolder deleteCharactersInRange:NSMakeRange(placeHolder.length-1, 1)];
//    }
//    
//    return placeHolder;
//}
//
//- (NSString *)sql_SelectUserInfoFromTable{
//    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",UserInfoTableName,WGPNAME(WGAuto_MOBILEPHONE)];
//}
//- (NSString *)sql_SelectLastLoginUserInfoFromTable{
//    return [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC",UserInfoTableName,WGPNAME(WGAuto_LastLoginTimestamp)];
//}
//- (NSString *)sql_InsertLocalUserInfoIntoTableWithColumns:(NSArray *)columnModels{
//    return [NSString
//            stringWithFormat:@"INSERT OR REPLACE INTO %@ VALUES (%@)",
//            UserInfoTableName,
//            [self placeHolderWithArray:columnModels]
//            ];
//}
//- (NSString *)sql_UpdateLastLoginUserInfoIntoTableWithColumns:(NSArray *)columnModels
//                                                        Where:(NSString *)where{
//    return [NSString
//            stringWithFormat:
//            @"UPDATE %@ SET VALUES (%@) WHERE %@ = ?",
//            UserInfoTableName,
//            [self placeHolderWithArray:columnModels],
//            where];
//}
//
//
//@end
