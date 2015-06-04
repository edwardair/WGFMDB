//
//  SnailUserInfoManager.h
//  Snail
//
//  Created by RayMi on 15/4/4.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "SnailPublicStroageHelper.h"
#import "LocalUserInfoModel.h"
#import "UserInfoDao.h"
/**
 *  用户数据管理
 */
@interface SnailUserInfoManager : SnailPublicStroageHelper
@property (nonatomic,readonly) UserInfoDao *dao;

@property (nonatomic,strong) LocalUserInfoModel *localUserInfoModel;

/**
 *  拉取用户金币，更新数据库
 */
- (void)updateUserBalance;

- (void)updateUserInfo;
@end
