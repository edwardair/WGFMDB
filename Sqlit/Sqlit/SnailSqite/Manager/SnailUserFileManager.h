//
//  SnailUserInfoManager.h
//  Snail
//
//  Created by RayMi on 15/4/4.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "UserFileDao.h"
/**
 *  用户数据管理
 */
@interface SnailUserFileManager : NSObject
+ (instancetype)shared;
@property (nonatomic,readonly) UserFileDao *dao;


@end
