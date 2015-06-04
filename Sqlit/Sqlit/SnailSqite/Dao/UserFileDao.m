//
//  UserFileDao.m
//  Snail
//
//  Created by 丝瓜&冬瓜 on 15/4/5.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "UserFileDao.h"
#import "UserFileDataBase.h"
#import "Define.h"
#import <WGCategory/WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"
@implementation UserFileDao
+ (instancetype)dao{
    static id dao;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dao = [[[self class]alloc]init];
    });
    
    return dao;
}

#pragma mark - 设置默认的database
- (void)setupDataBase {
    [super setupDataBase:[UserFileDataBase shared]];
}
- (void)setupFilePathModel {
    [super setupFilePathModel];
}

#pragma mark - db create
- (BOOL)openWithUserMobile:(NSString *)userMobile {
    //动态修改 dataBase路径
    if (userMobile.length == 0) {
        WGLogError(@"userMobile不能为空，开库失败!");
        return NO;
    }
    
    //动态  修改数据库路径
    [super
     setupFilePathModelWithType:kWGPathTypeDocuments
     FileInDirectory:[NSString
                      stringWithFormat:
                      @"%@/%@/%@", SnailDirectory,
                      PrivateUserDirectory(userMobile),
                      PrivateUserFilesDirectory(userMobile)]
     FileName:PrivateUserFilesDBName];
    
    return [super open];
}


#pragma mark - select
- (NSArray *)filesWithPage:(int )page AndPageSize:(int )pgSize{
    NSMutableArray *array = @[].mutableCopy;
    
     WEAKSELF
    
    NSString *sql = [(UserFileDataBase *)weakSelf.dataBase sql_SelectUserFilesFromTable];
    
    [self.readOnlyQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql, @((page-1)*pgSize), @(pgSize)];
        while ([rs next]) {
            UserFileModel *model = [UserFileModel modelWithResultSet:rs];
            [array addObject:model];
        }
        [rs close];
    }];
    
    return array;

}

- (UserFileModel *)lastFileModel{
    __block UserFileModel *fileModel = nil;
    
    WEAKSELF
    
    NSString *sql = [(UserFileDataBase *)weakSelf.dataBase sql_SelectLastUserFilesFromTable];
    
    [self.readOnlyQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            fileModel = [UserFileModel modelWithResultSet:rs];
            break;
        }
        [rs close];
    }];
    
    return fileModel;

}
#pragma mark - update or insert
- (UserFileModel *)asyncInsertFile:(UserFileModel *)model{
    __block UserFileModel *fileModel = nil;
    WEAKSELF
    
    NSString *sql = [(UserFileDataBase *)weakSelf.dataBase sql_InsertFile];
    
    [self.writableQueue inDatabase:^(FMDatabase *db) {
        
        BOOL scuess = [db
                       executeUpdate:sql, model.WGAuto_fileName, model.WGAuto_filePath,
                       @(model.WGAuto_fileSize),
                       [NSNumber numberWithDouble:model.WGAuto_downloadTimestamp],
                       [NSNumber numberWithDouble:model.WGAuto_lastReadTimestamp],
                       [NSNumber numberWithBool:model.WGAuto_didRead]];
        if (scuess) {
            fileModel = [weakSelf lastFileModel];
        }
    }];
    
    return fileModel;
}

- (BOOL)asyncUpdateFileReadStateWithIdentifier:(NSInteger )identifier{
    WEAKSELF
    
    __block BOOL flag = NO;
    
    NSString *sql = [(UserFileDataBase *)
                     weakSelf.dataBase sql_UpdateReadState];
    
    [self.writableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql,
                @YES,[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970]],@(identifier)];
        
        if (!flag) {
            WGLogError(@"UserFileModel 更新已读、阅读时间失败!");
        }
        
    }];
    
    return flag;
}
#pragma mark - delete
- (BOOL)asyncRemoveFileWithIdentifier:(NSInteger )identifier{
    WEAKSELF
    
    __block BOOL flag = NO;
    
    NSString *sql = [(UserFileDataBase *)
                     weakSelf.dataBase sql_RemoveFile];
    
    [self.writableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql,@(identifier)];
        
        if (!flag) {
            WGLogError(@"UserFileModel 删除失败!");
        }
        
    }];
    
    return flag;
}


@end
