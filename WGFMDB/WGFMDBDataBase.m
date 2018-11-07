//
//  WGFMDBDateBaseManager.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBase.h"
#import <WGKit/WGDefines.h>
#import "WGEasyEspecialColumnTypeProtocol.h"
#import "WGFMDBDataBase+SQLAppend.h"

@interface WGFMDBDataBase()

@property(nonatomic, strong) FMDatabaseQueue *writeableQueue;
@property(nonatomic, strong) FMDatabaseQueue *readonlyQueue;

//是否已打开
@property(nonatomic, assign) BOOL isOpened;

//记录上一次dataBase的路径，方便下一次开库前检测路径是否更改
@property(nonatomic, strong) WGFilePathModel*lastFilePath;

@end



@implementation WGFMDBDataBase
@synthesize pathModel = _pathModel;

#pragma mark - outer methods
- (BOOL)open{
    @synchronized(self){
        
        if (_isOpened) {
            /**
             *  如果数据库打开状态，检测数据库路径是否相同，不同的则关闭数据库，重新初始化数据库
             *  路径相同，则直接返回YES
             */
            if ([self.lastFilePath.fullPath isEqualToString:self.pathModel.fullPath]) {
                return YES;
            }else{
                [self closeAll];
            }
            
        }
        
        //初始化成功，则db文件默认已存在
        if (![self setupDatabaseQueue]) {
            return NO;
        }

#if DEBUG
        //!!!:重新检测下 db文件是否存在，理论上不需要检测
        NSAssert([self isDBFileExist], @"databaseQueue初始化成功，但是检测db文件不存在");
#endif
        
        _isOpened = YES;
        
        return _isOpened;

    }
}

- (void)closeAll{
    @synchronized(self) {
        if (self.writeableQueue) {
            [self.writeableQueue close];
            self.writeableQueue = nil;
        }
        if (self.readonlyQueue) {
            [self.readonlyQueue close];
            self.readonlyQueue = nil;
        }

        _isOpened = NO;
    }
}
- (void)removeDBFile{
    @synchronized(self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.pathModel.fullPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.pathModel.fullPath error:nil];
        }
    }
}
- (void)closeAndRemoveDBFile{
    [self closeAll];
    [self removeDBFile];
}


#pragma mark - getter
- (FMDatabaseQueue *)readonlyQueue{
    @synchronized(self){
        return _readonlyQueue;
    }
}
- (FMDatabaseQueue *)writeableQueue{
    @synchronized(self){
        return _writeableQueue;
    }
}

- (WGFilePathModel *)pathModel{
    if (!_pathModel) {
        _pathModel = [WGFilePathModel modelWithType:kWGPathTypeTmp FileInDirectory:nil];
        _pathModel.fileName = @"WGDefaultDB.db";
    }
    return _pathModel;
}
- (void)setPathModel:(WGFilePathModel *)pathModel{
    //临时赋值给_lastFilePath，以便记录上一次更改状态
    if (!_pathModel) {
        _pathModel = pathModel;
        _lastFilePath = _pathModel;
    }else{
        _lastFilePath = _pathModel;
        _pathModel = pathModel;
    }
}


#pragma mark - privite methods
- (BOOL )isDBFileExist{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.pathModel.fullPath isDirectory:NULL];
}

- (BOOL )setupDatabaseQueue{
    @synchronized(self){
        if (!_readonlyQueue) {
            FMDatabase *db = [self getDB];
            if (!db) {
                return NO;
            }

            _readonlyQueue = [FMDatabaseQueue databaseQueueWithPath:db.databasePath];
        }
        
        if (!_writeableQueue) {
            FMDatabase *db = [self getDB];
            if (!db) {
                return NO;
            }
            _writeableQueue = [FMDatabaseQueue databaseQueueWithPath:db.databasePath];

        }
        
        return YES;
    }
}


#pragma mark - 需要子类实现具体方法  一般无须overwrite
- (BOOL)createTable:(Class)tableClass InDataBase:(FMDatabase *)db{
    //重复调用open，不会引起重复开库
    if (![self open]) {
        WGLogError(@"建表前，尝试开库失败！！");
        return NO;
    }
    
    __block BOOL flag = NO;
    if ([db tableExists:[tableClass getTableName]]) {
        flag = [self appendTableColumnIfNotExistWithOwnClass:tableClass InDataBase:db];
    }else{
        NSString *sql = [self sql_getTableCreatStringWithOwnClass:tableClass];
        
        flag = [db executeUpdate:sql];
    }
    
    return flag;
    
}

- (BOOL)appendTableColumnIfNotExistWithOwnClass:(Class )ownClass InDataBase:(FMDatabase *)db{
    u_int outCount;
    objc_property_t *properties = class_copyPropertyList(ownClass, &outCount);
    BOOL success = YES;
    for (u_int i = 0; i < outCount; i++) {
        const char *propertyName_CStr = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:propertyName_CStr];
        if (![db columnExists:propertyName
              inTableWithName:[ownClass getTableName]]) {
            NSString *sql = [self sql_getAddANewColumnWithName:propertyName OwnClass:ownClass];
            
            success = [db executeUpdate:sql];
            
            if (!success) {
                WGLogFormatError(@"表增加字段：%@失败",propertyName);
                return NO;
            }
        }
    }
    free(properties);
    return success;
}

#pragma mark -
- (FMDatabase *)getDB{
    FMDatabase *db = [FMDatabase databaseWithPath:self.pathModel.fullPath];
    if (!db) {
        return nil;
    }
    
    if (![db open]) {
#if DEBUG
        NSAssert(0, @"DB开库失败");
#endif
        return nil;
    }
    
    return db;
}




@end
