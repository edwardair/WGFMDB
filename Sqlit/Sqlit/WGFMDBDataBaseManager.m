//
//  WGFMDBDateBaseManager.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBaseManager.h"
@interface WGFMDBDataBaseManager()

@property(nonatomic, strong) FMDatabaseQueue *writableQueue;
@property(nonatomic, strong) FMDatabaseQueue *readOnlyQueue;

@property (nonatomic,assign) BOOL isOpened;//是否已打开

@end



@implementation WGFMDBDataBaseManager
- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/**
 *  默认初始化数据
 */
- (void)defaultSetup{
    
}


#pragma mark - outer methods
- (BOOL)open{
    
    @synchronized(self){
        
        if (_isOpened) {
            return YES;
        }
        
        //先检测db文件是否存在，不存在，后面需要初始化db的数据库
        BOOL isDBFileExist = [self isDBFileExist];

        //初始化成功，则db文件默认已存在
        if (![self setupDatabaseQueue]) {
            return NO;
        }

        //!!!:重新检测下 db文件是否存在，理论上不需要检测
        NSAssert(!isDBFileExist, @"databaseQueue初始化成功，但是检测db文件不存在");

        
        //以下操作都为数据库打开状态，在 数据库操作 失败后，需要关闭库、及相应的清空数据操作

        
        if (!isDBFileExist) {
            if ([self respondsToSelector:@selector(onCreate:)]) {
                
            }
            [self onCreate:self.writableQueue];
        }

        
        
    }
    
    
    return YES;
}

- (void)closeAll{
    
}
- (void)closeAndRemoveDBFile{
    
}

#pragma mark - getter
- (FMDatabaseQueue *)readOnlyQueue{
    @synchronized(self){
        return _readOnlyQueue;
    }
}
- (FMDatabaseQueue *)writableQueue{
    @synchronized(self){
        return _writableQueue;
    }
}


- (FMDatabase *)getDB{
    FMDatabase *db = [FMDatabase databaseWithPath:_pathModel.fullPath];
    if (!db) {
        return nil;
    }
    
    if (![db open]) {
        assert(@"DB开库失败");
        return nil;
    }
    
    return db;
}




#pragma mark - privite methods
- (BOOL )isDBFileExist{
    return [[NSFileManager defaultManager] fileExistsAtPath:_pathModel.fullPath isDirectory:NULL];
}

- (BOOL )setupDatabaseQueue{
    @synchronized(self){
        if (!_readOnlyQueue) {
            FMDatabase *db = [self getDB];
            if (!db) {
                return NO;
            }

            _readOnlyQueue = [FMDatabaseQueue databaseQueueWithPath:db.databasePath];
        }
        
        if (!_writableQueue) {
            FMDatabase *db = [self getDB];
            if (!db) {
                return NO;
            }
            _writableQueue = [FMDatabaseQueue databaseQueueWithPath:db.databasePath];

        }
        
        return YES;
    }
}

@end
