//
//  UserFileDao.h
//  Snail
//
//  Created by 丝瓜&冬瓜 on 15/4/5.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "WGFMDBBaseDao.h"
#import "UserFileModel.h"
@interface UserFileDao : WGFMDBBaseDao
#pragma mark - create
/**
 *  开库
 */
- (BOOL)openWithUserMobile:(NSString *)userMobile;

#pragma mark - select
- (NSArray *)filesWithPage:(int )page AndPageSize:(int )pgSize;
- (UserFileModel *)lastFileModel;

#pragma mark - update or insert
/**
 *  插入一个model
 *
 *  @param model 需要插入的model
 *
 *  @return 插入成功后，从数据库中读取此model，携带有identifier属性
 */
- (UserFileModel *)asyncInsertFile:(UserFileModel *)model;
/**
 *  更新为已读，同时更新lastReadTimeStramp为当前时间点，暂时忽略文件关闭时间
 *
 *  @param identifier 从数据库中读取的id字段
 *
 *  @return 成功失败
 */
- (BOOL)asyncUpdateFileReadStateWithIdentifier:(NSInteger )identifier;

#pragma mark - delete
/**
 *  删除文件
 *
 *  @param identifier 从数据库中读取的id字段
 *
 *  @return 成功失败
 */
- (BOOL)asyncRemoveFileWithIdentifier:(NSInteger )identifier;

@end
