//
//  UserInfoDataBase.h
//  Snail
//
//  Created by RayMi on 15/3/28.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "WGFMDBDataBase.h"

/**
 *  用户下载文件数据库
 */
@interface UserFileDataBase : WGFMDBDataBase

#pragma mark - SQL 语句
- (NSString *)sql_SelectUserFilesFromTable;
- (NSString *)sql_SelectLastUserFilesFromTable;
- (NSString *)sql_InsertFile;
- (NSString *)sql_UpdateReadState;
- (NSString *)sql_RemoveFile;
@end
