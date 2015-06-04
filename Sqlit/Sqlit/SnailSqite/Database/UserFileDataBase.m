//
//  UserInfoDataBase.m
//  Snail
//
//  Created by RayMi on 15/3/28.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "UserFileDataBase.h"
#import "UserFileModel.h"
#import "Define.h"
#import <WGCategory/WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"

#define UserFileTableName @"USERFILE_TABLE"

@implementation UserFileDataBase
+ (instancetype)shared{
    static id defaultDataBase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDataBase = [[[self class] alloc]init];
    });
    return defaultDataBase;
}

#pragma mark - 建表
- (BOOL)onCreateTable:(FMDatabaseQueue *)dbQueue {
    __block BOOL flag = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString
                         stringWithFormat:
                         @"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT 0, %@ TEXT, %@ TEXT, %@ INT, %@ DOUBLE, %@ DOUBLE, %@ BIT)",
                         UserFileTableName, WGPNAME(WGAuto_identifier),
                         WGPNAME(WGAuto_fileName), WGPNAME(WGAuto_filePath),
                         WGPNAME(WGAuto_fileSize), WGPNAME(WGAuto_downloadTimestamp),
                         WGPNAME(WGAuto_lastReadTimestamp), WGPNAME(WGAuto_didRead)];
        
        flag = [db executeUpdate:sql];
        
    }];
    
    return flag;
}


#pragma mark - SQL 语句
- (NSString *)sql_SelectUserFilesFromTable {
    return [NSString
            stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC LIMIT ?,?",
            UserFileTableName, WGPNAME(WGAuto_identifier)];
}
- (NSString *)sql_SelectLastUserFilesFromTable {
    return [NSString
            stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC",
            UserFileTableName, WGPNAME(WGAuto_identifier)];
}

- (NSString *)sql_InsertFile {
    return [NSString
            stringWithFormat:
            @"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?)",
            UserFileTableName, WGPNAME(WGAuto_fileName), WGPNAME(WGAuto_filePath),
            WGPNAME(WGAuto_fileSize), WGPNAME(WGAuto_downloadTimestamp),
            WGPNAME(WGAuto_lastReadTimestamp), WGPNAME(WGAuto_didRead)];
}
- (NSString *)sql_UpdateReadState {
    return [NSString
            stringWithFormat:@"UPDATE %@ SET %@ = ?,%@ = ? WHERE %@ = ?",
            UserFileTableName, WGPNAME(WGAuto_didRead),
            WGPNAME(WGAuto_lastReadTimestamp),
            WGPNAME(WGAuto_identifier)];
}
- (NSString *)sql_RemoveFile {
    return
    [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
     UserFileTableName, WGPNAME(WGAuto_identifier)];
}
@end
