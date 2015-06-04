//
//  UserInfoDao.h
//  Snail
//
//  Created by 丝瓜&冬瓜 on 15/4/3.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "WGFMDBBaseDao.h"
#import "LocalUserInfoModel.h"

@interface UserInfoDao : WGFMDBBaseDao
#pragma mark - create
/**
 *  开库
 */
- (BOOL)openWithUserMobile:(NSString *)userMobile;

#pragma mark - select
/**
 *  获取当前登录设备的UserInfoModel
 */
- (LocalUserInfoModel *)userInfoWithMobile:(NSString *)userMobile;

/**
 *  获取上一次最后登录设备的UserInfoModel
 */
- (LocalUserInfoModel *)lastLoginUserInfo;

#pragma mark - update or insert
/**
 *  异步 更新用户数据
 *
 *  @param userInfoModel UserInfoModel
 *
 *  @return 成功失败
 */
- (BOOL)asyncUpdateLocalUserInfo:(LocalUserInfoModel *)localUserInfoModel;

/**
 *  异步 插入、替换 用户数据
 *
 *  @param localUserInfoModel LocalUserInfoModel
 *
 *  @return 成功失败
 */
- (BOOL)asyncInsertLocalUserInfo:(LocalUserInfoModel *)localUserInfoModel;

@end
