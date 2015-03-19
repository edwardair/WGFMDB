//
//  WGFMDBDateBaseManager.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBase.h"
@interface WGFMDBDataBase()

@property(nonatomic, strong) FMDatabaseQueue *writableQueue;
@property(nonatomic, strong) FMDatabaseQueue *readOnlyQueue;

@property (nonatomic,assign) BOOL isOpened;//是否已打开

@end



@implementation WGFMDBDataBase

#pragma mark - outer methods

+ (instancetype)shared{
    static id defaultDataBase;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDataBase = [[[self class] alloc]init];
    });
    return defaultDataBase;
}

- (BOOL)open{
    @synchronized(self){
        
        if (_isOpened) {
            NSLog(@"数据库已打开");
            return YES;
        }
        
        //先检测db文件是否存在，不存在，后面需要初始化db的数据库
        BOOL isDBFileExist = [self isDBFileExist];

        //初始化成功，则db文件默认已存在
        if (![self setupDatabaseQueue]) {
            return NO;
        }

        //!!!:重新检测下 db文件是否存在，理论上不需要检测
        NSAssert([self isDBFileExist], @"databaseQueue初始化成功，但是检测db文件不存在");

        
        //以下操作都为数据库打开状态，在 数据库操作 失败后，需要关闭库、及相应的清空数据操作

        //数据库文件不存在情况下，需要创建需要的表
        if (!isDBFileExist) {
            //如果“子类”未引用WGFMDBDataBaseDelegate协议（本类未引用此协议，故可以区分父子类），则会报错，必须由子类实现必要方法
            if (![[self class]conformsToProtocol:@protocol(WGFMDBDataBaseDelegate)]) {
                [self closeAndRemoveDBFile];

                NSAssert(NO, @"需要子类引用WGFMDBDataBaseDelegate协议并实现必要的方法");
                return NO;
            }else{
                //数据库创建表
                if (![self onCreateTable:self.writableQueue]) {
                    [self closeAndRemoveDBFile];
                    return NO;
                }
            }
        }

        _isOpened = YES;
        
    }
    
    
    return YES;
}

- (void)closeAll{
    @synchronized(self) {
        if (self.writableQueue) {
            [self.writableQueue close];
            self.writableQueue = nil;
        }
        if (self.readOnlyQueue) {
            [self.readOnlyQueue close];
            self.readOnlyQueue = nil;
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

/**
 *  需要子类实现具体方法
 *
 */
- (BOOL)onCreateTable:(FMDatabaseQueue *)dbQueue{
    [self closeAndRemoveDBFile];

    NSAssert(NO, @"数据库不存在情况下，需要创建表，子类需要实现onCreate: 方法");
    
    return NO;
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


#pragma mark - Initializer
- (id)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup{
    _pathModel = [WGFilePathModel modelWithType:Caches FileInDirectory:nil];
    _pathModel.fileName = @"WGDefaultDB.db";
}
@end
