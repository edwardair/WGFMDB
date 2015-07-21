
//
//  WGEasyManager.m
//  Sqlit
//
//  Created by RayMi on 15/6/25.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGEasyManager.h"
#import "NSObject+WGModelValue.h"

@interface WGEasyManager : NSObject

#define DATABASEINFO(dbBase,filepath) @{@"database":dbBase,@"filepath":filepath}
#define DATABASE(database) database[@"database"]
#define FILEPATH(database) database[@"filepath"]

/**
 *  @{className:DATABASE}
 */
@property (nonatomic,strong) NSMutableDictionary *DBs;
@end
@implementation WGEasyManager
+ (instancetype)shared{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}
- (id )init{
    if (self=[super init]) {
        _DBs = @{}.mutableCopy;
    }
    return self;
}

#pragma mark -
- (BOOL)registerTable:(Class )class AtPath:(WGFilePathModel *(^)())pathModelBlock{
    @synchronized(self){
        //表 名称
        NSString *tableName = NSStringFromClass(class);
        
        WGFilePathModel *pathModel = pathModelBlock();
        if (!pathModel) {
            pathModel = [WGFilePathModel modelWithType:kWGPathTypeTmp
                                       FileInDirectory:nil];
            pathModel.fileName = @"WGEasyDB.db";
        }
        
        BOOL isClassRegisted = NO;
        
        NSDictionary *dataBase = _DBs[tableName];
        WGFilePathModel *existPathModel;
        WGFMDBDataBase *existDbBase;
        if (dataBase) {
            existPathModel = FILEPATH(dataBase);
            existDbBase = DATABASE(dataBase);
            isClassRegisted = YES;
        }
        
        //class已注册过
        if (isClassRegisted) {
            //检测路径是否相同，相同的则忽略开库
            if ([existDbBase.pathModel.fullPath isEqualToString:pathModel.fullPath]) {
                //路径相同，不需要重复开库
                //同时class也注册过，不需要重复检测table是否创建，表字段是否已增加
                return YES;
            }else{
                //路径不同，需要先注销当前的
                [self resignTable:class];
                //开库
                BOOL success = [self openDBWithFilePathModel:pathModel
                                            OwnClass:class
                                ExistDataBase:nil];
                return success;
            }
        }else{
            //开库
            BOOL success = [self openDBWithFilePathModel:pathModel
                                                OwnClass:class
                            ExistDataBase:existDbBase];
            return success;
        }
        
        
        return NO;
    }
}
- (BOOL)openDBWithFilePathModel:(WGFilePathModel *)pathModel
                       OwnClass:(Class )ownClass
                  ExistDataBase:(WGFMDBDataBase *)dataBase{
    if (!dataBase) {
        dataBase = [[WGFMDBDataBase alloc]init];
        dataBase.pathModel = pathModel;
    }
    __block BOOL success = [dataBase open];
    if (success) {
        //成功，继续检测table是否存在
        [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
            success = [dataBase createTable:ownClass
                                 InDataBase:db];
        }];
    }
    
    if (success) {
        //存入临时数组
        [_DBs setObject:DATABASEINFO(dataBase, pathModel) forKey:NSStringFromClass(ownClass)];
    }
    
    return success;
}
- (BOOL)resignTable:(Class )class{
    if (class==Nil) {
        WGLogError(@"class不存在，无法删除");
        return NO;
    }
    NSString *tableName = NSStringFromClass(class);
    NSDictionary *exist = _DBs[tableName];

    if (exist) {
        [_DBs removeObjectForKey:NSStringFromClass(class)];
        
        WGFMDBDataBase *existDbBase = DATABASE(exist);
        BOOL close = YES;
        //检测_DBs中，是否还存在相同的existDbBase
        for (NSDictionary *e in _DBs.allValues) {
            WGFMDBDataBase *dbBase = DATABASE(e);
            if ([dbBase isEqual:existDbBase]) {
                close = NO;
                break;
            }
        }
        if (class) {
            [existDbBase closeAll];
        }
        
    }

    return YES;
}

#pragma mark -
- (BOOL)insertIntoTableWithModel:(id )model{
    return [self insertIntoTableWithModel:model
                               ExceptKeys:nil];
}
- (BOOL)insertIntoTableWithModel:(id )model ExceptKeys:(NSArray *)keys{
    if (!model) {
        WGLogError(@"model 不存在，无法存入数据库");
        return NO;
    }
    
    Class ownClass = [model class];
    
    WGFMDBDataBase *dataBase = DATABASE(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        WGLogError(@"dataBase 不存在，无法使用数据库");
        return NO;
    }
    
    NSArray *columnModels =
    [WGFMDBColumnModel getColumnsWithClass:ownClass Excepts:keys];
    if (columnModels.count==0) {
        WGLogFormatError(@"%@未查找到需要存入数据库中的属性字段",NSStringFromClass(ownClass));
        return NO;
    }
    //二次过滤model属性对应的值为空时，对应的key将不存在字典中，此时需要将columnModels中对应的过滤掉
    NSDictionary *modelValue = [model modelValue];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(WGFMDBColumnModel *evaluatedObject, NSDictionary *bindings) {
        return [modelValue.allKeys containsObject:evaluatedObject.columnName];
    }];
    columnModels = [columnModels filteredArrayUsingPredicate:predicate];
    
    __block BOOL flag = NO;
    NSString *sql = [dataBase sql_insertModelIntoTableWithColumns:columnModels
                                                         OwnClass:ownClass];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql
         withParameterDictionary:modelValue
                ];
        
        if (!flag) {
            WGLogFormatError(@"%@ 插入、替换失败!",NSStringFromClass(ownClass));
        }
        
    }];
    
    return flag;
}
//TODO: 更新操作时，由于[model modelValue]在转化时，不会将空值的属性存入字典，导致key不存在，数据库字段无法对应的问题
- (BOOL)updateIntoTableWithModel:(id )model
                           Where:(NSArray *)keys
                 OnlyUpdateThese:(NSArray *)theseKeys{
    if (!model) {
        WGLogError(@"存储的model不存在");
        return NO;
    }
    
    Class ownClass = [model class];
    
    WGFMDBDataBase *dataBase = DATABASE(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        WGLogError(@"dataBase不存在，无法使用数据库");
        return NO;
    }
    
    //需要更新的字段，为过滤“全局”“临时”两种情况后的数组
    NSArray *needUpdateColumnModels = [WGFMDBColumnModel getColumnsWithClass:ownClass Excepts:nil];
    NSDictionary *modelValue = [model modelValue];
    //将columnModels第三次过滤modelValue、keys、theseKeys中仅有的key
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(WGFMDBColumnModel *evaluatedObject, NSDictionary *bindings) {
        return ([modelValue.allKeys containsObject:evaluatedObject.columnName] &&
        (theseKeys.count?[theseKeys containsObject:evaluatedObject.columnName]:YES));
    }];
    needUpdateColumnModels = [needUpdateColumnModels filteredArrayUsingPredicate:predicate];
    
    if (needUpdateColumnModels.count==0) {
        WGLogFormatError(@"%@未查找到需要存入数据库中的属性字段",NSStringFromClass(ownClass));
        return NO;
    }
    
    __block BOOL flag = NO;
    NSString *sql = [dataBase sql_updateModelIntoTableWithColumns:needUpdateColumnModels
                                                            Where:keys
                                                         OwnClass:ownClass];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql
         withParameterDictionary:modelValue];
        
        if (!flag) {
            WGLogFormatError(@"%@ 插入、替换失败!",NSStringFromClass(ownClass));
        }
        
    }];
    
    return flag;
}

- (NSArray *)selectFromTableWithOwnClass:(Class )ownClass
                          UsingKeyValues:(NSDictionary *)keyValues
                                   OrderBy:(NSArray *)orderBy
                                    Offset:(int)offset
                                       Len:(int)len{
    if (ownClass==Nil) {
        return nil;
    }
    
    WGFMDBDataBase *dataBase = DATABASE(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        return nil;
    }
    
    NSMutableArray *models = @[].mutableCopy;
    NSString *sql = [dataBase sql_selectModelFromTableWhere:keyValues.allKeys
                                                   OwnClass:ownClass
                                                    OrderBy:orderBy
                                                     Offset:offset
                                                        Len:len];
    
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql
                          withArgumentsInArray:keyValues.allValues];
        while ([result next]) {
            [models addObject:[ownClass modelWithResultSet:result]];
        }
        [result close];
    }];
    
    return models;
}

- (BOOL)deleteFromTableWithOwnClass:(Class )ownClass
                     UsingKeyValues:(NSDictionary *)keyValues{
    if (keyValues.allKeys.count==0) {
        return NO;
    }
    
    WGFMDBDataBase *dataBase = DATABASE(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        return NO;
    }
        
    __block BOOL flag = NO;
    NSString *sql = [dataBase sql_deleteModelFromTableWhere:keyValues.allKeys
                                                         OwnClass:ownClass];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql
         withParameterDictionary:keyValues
                ];
        
        if (!flag) {
            WGLogFormatError(@"%@ 插入、替换失败!",NSStringFromClass(ownClass));
        }
        
    }];
    
    return flag;
}

#pragma mark -
- (BOOL)executeWithModelClass:(Class )ownClass
                 executeBlock:(BOOL (^)(FMDatabase *db_))block{
    if (ownClass==Nil) {
        return NO;
    }
    
    WGFMDBDataBase *dataBase = DATABASE(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        return NO;
    }
    
    __block BOOL flag = NO;

    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = block(db);
    }];

    return YES;
}
@end



#pragma mark -
@implementation NSObject(WGEasyManager)
#pragma mark -
+ (BOOL)registerTableAtPath:(WGFilePathModel *(^)())pathModelBlock{
    return [[WGEasyManager shared]registerTable:self
                                         AtPath:pathModelBlock];
}

+ (BOOL)resignTable{
    return [[WGEasyManager shared]resignTable:self];
}

#pragma mark -
- (BOOL)executeInsertIntoTable{
    return [[WGEasyManager shared]insertIntoTableWithModel:self];
}

- (BOOL)executeInsertIntoTableExceptKeys:(NSArray *)keys{
    return [[WGEasyManager shared]insertIntoTableWithModel:self
                                                ExceptKeys:keys];
}

- (BOOL)executeUpdateIntoTableWhere:(NSArray *)keys{
    return [[WGEasyManager shared]updateIntoTableWithModel:self
                                                     Where:keys
                                           OnlyUpdateThese:nil];
}

- (BOOL)executeUpdateIntoTableWhere:(NSArray *)keys OnlyUpdateThese:(NSArray *)theseKeys{
    return [[WGEasyManager shared]updateIntoTableWithModel:self
                                                     Where:keys
                                           OnlyUpdateThese:theseKeys];
}

+ (NSArray *)executeSelectFromTableUsingKeyValues:(NSDictionary *)keyValues
                                          OrderBy:(NSArray *)orderBy
                                           Offset:(int)offset
                                              Len:(int)len {
    return [[WGEasyManager shared]selectFromTableWithOwnClass:self
                                               UsingKeyValues:keyValues
                                                      OrderBy:orderBy
                                                       Offset:offset
                                                          Len:len];
}

+ (NSArray *)executeSelectFromTableUsingKeyValues:(NSDictionary *)keyValues
                                          OrderBy:(NSArray *)orderBy{
    return [[WGEasyManager shared]selectFromTableWithOwnClass:self
                                               UsingKeyValues:keyValues
                                                      OrderBy:orderBy
                                                       Offset:-1
                                                          Len:-1];
}

+ (NSArray *)allTableModels{
    return [self executeSelectFromTableUsingKeyValues:nil
                                              OrderBy:nil];
}

+ (instancetype)firstModelUsingKeyValues:(NSDictionary *)keyValues
                                 OrderBy:(NSArray *)orderBy{
    return [[WGEasyManager shared]selectFromTableWithOwnClass:self
                                               UsingKeyValues:keyValues
                                                      OrderBy:orderBy
                                                       Offset:0 Len:1].firstObject;
}

+ (instancetype)lastModelUsingKeyValues:(NSDictionary *)keyValues
                                OrderBy:(NSArray *)orderBy{
    //此处len=-1，是使用了  len<=0的情况，不做offset偏移，正常获取到排序后的整组数据，取最后一个
    return [[WGEasyManager shared]selectFromTableWithOwnClass:self
                                               UsingKeyValues:keyValues
                                                      OrderBy:orderBy
                                                       Offset:0 Len:-1].lastObject;
}

+ (BOOL)executeDeleteFromTableUsingKeyValues:(NSDictionary *)keyValues{
    return [[WGEasyManager shared]deleteFromTableWithOwnClass:self
                                               UsingKeyValues:keyValues];
}

#pragma mark - 
+ (BOOL)executeWithBlock:(BOOL (^)(FMDatabase *db_))block{
    return [[WGEasyManager shared]executeWithModelClass:self
                                           executeBlock:block];
}

@end
