//
//  WGFMDBDateBaseManager.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBase.h"
#import "WGDefines.h"

@interface WGFMDBDataBase()

@property(nonatomic, strong) FMDatabaseQueue *writableQueue;
@property(nonatomic, strong) FMDatabaseQueue *readOnlyQueue;

@property (nonatomic,assign) BOOL isOpened;//是否已打开

@property (nonatomic,strong) WGFilePathModel *lastFilePath;//记录上一次dataBase的路径，方便下一次开库前检测路径是否更改

@end



@implementation WGFMDBDataBase
@synthesize pathModel = _pathModel;

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
        
        //先检测db文件是否存在，不存在，后面需要初始化db的数据库
        BOOL isDBFileExist = [self isDBFileExist];

        //初始化成功，则db文件默认已存在
        if (![self setupDatabaseQueue]) {
            return NO;
        }

#if DEBUG
        //!!!:重新检测下 db文件是否存在，理论上不需要检测
        NSAssert([self isDBFileExist], @"databaseQueue初始化成功，但是检测db文件不存在");
#endif
        
        //以下操作都为数据库打开状态，在 数据库操作 失败后，需要关闭库、及相应的清空数据操作

        //数据库文件不存在情况下，需要创建需要的表
        if (!isDBFileExist) {
            if (![self onCreateTable:self.writableQueue]) {
                [self closeAndRemoveDBFile];
                return NO;
            }
        }
        else{
            //数据库存在状态，检测表字段是否存在，不存在，则增加column
            [self appendTableColumnIfNotExist];
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


#pragma mark - getter
- (FMDatabaseQueue *)readonlyQueue{
    @synchronized(self){
        return _readOnlyQueue;
    }
}
- (FMDatabaseQueue *)writeableQueue{
    @synchronized(self){
        return _writableQueue;
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
    _lastFilePath = _pathModel;
    
    _pathModel = pathModel;
}


#pragma mark - privite methods
- (BOOL )isDBFileExist{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.pathModel.fullPath isDirectory:NULL];
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
#pragma mark - 需要子类实现具体方法  必须overwrite
- (NSString *)getTableName{
    NSAssert(0, @"需子类返回表名");
    return @"";
}
- (Protocol *)getModelBridgeToDBColumnProtocol{
    NSAssert(0, @"需要子类实现");
    return @protocol(WGFMDBBridgeProtocol);
}


#pragma mark - 需要子类实现具体方法  一般无须overwrite
- (BOOL)onCreateTable:(FMDatabaseQueue *)dbQueue{
    
    __block BOOL flag = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [self SQL_GetTableCreatString];
        
        flag = [db executeUpdate:sql];
        
    }];
    
    return flag;
    
}

- (void)appendTableColumnIfNotExist{
    u_int outCount;
    objc_property_t *properties = protocol_copyPropertyList([self getModelBridgeToDBColumnProtocol], &outCount);

    [self.writableQueue inDatabase:^(FMDatabase *db) {
        for (int i = 0; i < outCount; i++) {
            const char *protocolName_CStr = property_getName(properties[i]);
            NSString *protocolName = [NSString stringWithUTF8String:protocolName_CStr];
            if (![db columnExists:protocolName
                  inTableWithName:[self getTableName]]) {
                NSString *sql = [self SQL_GetAddANewColumnWithName:protocolName];
                
               BOOL scuess = [db executeUpdate:sql];
                if (!scuess) {
                    WGLogFormatError(@"表增加字段：%@失败",protocolName);
                }
            }
        }
    }];
    free(properties);
}

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


#pragma mark - SQL 语句
- (NSString *)placeHolderWithArray:(NSArray *)array{
    NSMutableString *placeHolder = [NSMutableString string];
    for (int i = 0; i < array.count; i++) {
        [placeHolder appendFormat:@"%@,",[array[i] placeHolder]];
    }
    
    if ([placeHolder hasSuffix:@","]) {
        [placeHolder deleteCharactersInRange:NSMakeRange(placeHolder.length-1, 1)];
    }
    
    return placeHolder;
}
/**
 *  获取建表时所有的column名，包含数据类型字符串
    注：column顺序是随机的
 */
- (NSString *)columnNames:(NSArray *)colmunModels appendColumnType:(BOOL)hasType{
    NSMutableString *str = @"".mutableCopy;
    for (WGFMDBColumnModel *model_ in colmunModels) {
        if (hasType) {
            [str appendFormat:@"%@ %@,",model_.columnName,model_.columnType];
        }else{
            [str appendFormat:@"%@,",model_.columnName];
        }
    }
    if ([str hasSuffix:@","]) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    return str;
}
/**
 *  获取建表SQL
 */
- (NSString *)SQL_GetTableCreatString {
    //??? : 是否可以创建空表？？
    return [NSString
            stringWithFormat:
            @"CREATE TABLE IF NOT EXISTS %@ (%@)", [self getTableName],
            [self columnNames:[WGFMDBColumnModel
                               getColumnsWithBridgeProtocol:
                               [self getModelBridgeToDBColumnProtocol]
                               Except:nil]
             appendColumnType:YES]];
}


- (NSString *)SQL_GetAddANewColumnWithName:(NSString *)columnName{
    WGFMDBColumnModel *model_ = [WGFMDBColumnModel modelWithName:columnName BridgeProtocol:[self getModelBridgeToDBColumnProtocol]];
    return [NSString
            stringWithFormat:
            @"ALTER TABLE %@ ADD %@ %@", [self getTableName], columnName,
            model_.columnType];
}


@end
