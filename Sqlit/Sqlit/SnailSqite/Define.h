//
//  Define.h
//  Sqlit
//
//  Created by RayMi on 15/6/4.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#ifndef Sqlit_Define_h
#define Sqlit_Define_h

#pragma mark - 数据库路径
#define SnailDirectory [@"SNAIL" md5]//用户数据存储跟目录

#define PublicUserInfoDirectory [@"PublicUserInfoDirectory" md5]//SnailDirectory目录下，用户公共数据存储目录，如  用户资料表
#define PublicUserInfoDBName [[@"PublicUserInfoDBName" md5] stringByAppendingString:@".db"]//用户表数据库名

#define PrivateUserDirectory(userMobile) [userMobile md5]//SnailDirectory目录下，用户私有数据存储目录

#define PrivateUserFilesDirectory(userMobile) [[@"DOWNLOAD_FILES" stringByAppendingString:userMobile] md5]//PrivateUserDirectory目录下，用户 下载文件数据存储目录
#define PrivateUserFilesDBName [[@"PrivateUserFilesDBName" md5] stringByAppendingString:@".db"]//用户下载文件数据库名

#endif
