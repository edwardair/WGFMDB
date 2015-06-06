//
//  UserInfoDataBase.h
//  Snail
//
//  Created by RayMi on 15/3/28.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "WGFMDBDataBase.h"

@interface UserInfoDataBase : WGFMDBDataBase

#pragma mark - SQL 语句
/**
 *  使用userMobile从用户表中查找对应的用户数据
 */
- (NSString *)sql_SelectUserInfoFromTable;
- (NSString *)sql_SelectLastLoginUserInfoFromTable;
- (NSString *)sql_InsertLocalUserInfoIntoTableWithColumns:(NSArray *)columnModels;
- (NSString *)sql_UpdateLastLoginUserInfoIntoTableWithColumns:(NSArray *)columnModels
                                                        Where:(NSString *)where;
@end
