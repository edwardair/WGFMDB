
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

#define DATABASE(dbBase,filepath) @{@"database":dbBase,@"filepath":filepath}
#define dbBase(database) database[@"database"]
#define filePath(database) database[@"filepath"]

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
            pathModel = [WGFilePathModel modelWithType:kWGPathTypeTmp FileInDirectory:nil];
            pathModel.fileName = @"WGEasyDB.db";
        }
        
        BOOL isClassRegisted = NO;
        
        NSDictionary *dataBase = _DBs[tableName];
        WGFilePathModel *existPathModel;
        WGFMDBDataBase *existDbBase;
        if (dataBase) {
            existPathModel = filePath(dataBase);
            existDbBase = dbBase(dataBase);
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
- (BOOL)openDBWithFilePathModel:(WGFilePathModel *)pathModel OwnClass:(Class )ownClass ExistDataBase:(WGFMDBDataBase *)dataBase{
    if (!dataBase) {
        dataBase = [[WGFMDBDataBase alloc]init];
        dataBase.pathModel = pathModel;
    }
    __block BOOL success = [dataBase open];
    if (success) {
        //成功，继续检测table是否存在
        [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
            success = [dataBase createTable:ownClass InDataBase:db];
        }];
    }
    
    if (success) {
        //存入临时数组
        [_DBs setObject:DATABASE(dataBase, pathModel) forKey:NSStringFromClass(ownClass)];
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
        
        WGFMDBDataBase *existDbBase = dbBase(exist);
        BOOL close = YES;
        //检测_DBs中，是否还存在相同的existDbBase
        for (NSDictionary *e in _DBs.allValues) {
            WGFMDBDataBase *dbBase = dbBase(e);
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
    return [self insertIntoTableWithModel:model ExceptKeys:nil];
}
- (BOOL)insertIntoTableWithModel:(id )model ExceptKeys:(NSArray *)keys{
    if (!model) {
        WGLogError(@"model 不存在，无法存入数据库");
        return NO;
    }
    
    Class ownClass = [model class];
    
    WGFMDBDataBase *dataBase = dbBase(_DBs[NSStringFromClass(ownClass)]);
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
    
    __block BOOL flag = NO;
    NSString *sql = [dataBase sql_insertModelIntoTableWithColumns:columnModels
                                                         OwnClass:ownClass];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql withParameterDictionary:[model modelValue]
                ];
        
        if (!flag) {
            WGLogFormatError(@"%@ 插入、替换失败!",NSStringFromClass(ownClass));
        }
        
    }];
    
    return flag;
    
    return NO;
}
- (BOOL)updateIntoTableWithModel:(id )model UsingKeys:(NSArray *)keys{
    if (!model) {
        return NO;
    }
    
    Class ownClass = [model class];
    
    WGFMDBDataBase *dataBase = dbBase(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        return NO;
    }
    
    NSMutableArray *columnModels = @[].mutableCopy;
    for (NSString *key in keys) {
        [columnModels addObject:[WGFMDBColumnModel modelWithName:key OwnClass:ownClass]];
    }
    
    if (columnModels.count==0) {
        WGLogFormatError(@"%@未查找到需要存入数据库中的属性字段",NSStringFromClass(ownClass));
        return NO;
    }
    
    __block BOOL flag = NO;//UPDATE %@ SET %@ = ? WHERE %@ = ?"
    NSString *sql = [dataBase sql_updateModelIntoTableWithColumns:columnModels
                                                            Where:keys
                                                         OwnClass:ownClass];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql withParameterDictionary:[model modelValue]
                ];
        
        if (!flag) {
            WGLogFormatError(@"%@ 插入、替换失败!",NSStringFromClass(ownClass));
        }
        
    }];
    
    return flag;
}
- (NSArray *)selectFromTableWithOwnClass:(Class )ownClass UsingKeyValues:(NSDictionary *)keyValues OrderBy:(kQueryOrderBy)orderBy{
    if (ownClass==Nil) {
        return nil;
    }
    
    WGFMDBDataBase *dataBase = dbBase(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        return nil;
    }
    
    NSMutableArray *models = @[].mutableCopy;
    NSString *sql = [dataBase sql_selectModelFromTableWhere:keyValues.allKeys
                                                   OwnClass:ownClass
                                                    OrderBy:orderBy];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sql withArgumentsInArray:keyValues.allValues];
        while ([result next]) {
            [models addObject:[ownClass modelWithResultSet:result]];
        }
    }];
    
    return models;
}
- (BOOL)deleteFromTableWithModel:(id )model UsingKeys:(NSArray *)keys{
    if (!model) {
        return NO;
    }
    
    Class ownClass = [model class];
    
    WGFMDBDataBase *dataBase = dbBase(_DBs[NSStringFromClass(ownClass)]);
    if (!dataBase) {
        return NO;
    }
        
    __block BOOL flag = NO;
    NSString *sql = [dataBase sql_deleteModelFromTableWhere:keys
                                                         OwnClass:ownClass];
    [dataBase.writeableQueue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql withParameterDictionary:[model modelValue]
                ];
        
        if (!flag) {
            WGLogFormatError(@"%@ 插入、替换失败!",NSStringFromClass(ownClass));
        }
        
    }];
    
    return flag;
}

#pragma mark -
- (BOOL)executeWithModel:(id )model executeBlock:(BOOL (^)(FMDatabase *db_))block{
    if (!model) {
        return NO;
    }
    
    Class ownClass = [model class];
    
    WGFMDBDataBase *dataBase = dbBase(_DBs[NSStringFromClass(ownClass)]);
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
    return [[WGEasyManager shared]registerTable:self AtPath:pathModelBlock];
}
+ (BOOL)resignTable{
    return [[WGEasyManager shared]resignTable:self];
}

#pragma mark -
- (BOOL)insertIntoTable{
    return [[WGEasyManager shared]insertIntoTableWithModel:self];
}
- (BOOL)insertIntoTableExceptKeys:(NSArray *)keys{
    return [[WGEasyManager shared]insertIntoTableWithModel:self ExceptKeys:keys];
}
- (BOOL)updateIntoTableUsingKeys:(NSArray *)keys{
    return [[WGEasyManager shared]updateIntoTableWithModel:self UsingKeys:keys];
}
+ (NSArray *)selectFromTableUsingKeyValues:(NSDictionary *)keyValues OrderBy:(kQueryOrderBy)orderBy{
    return [[WGEasyManager shared]selectFromTableWithOwnClass:self UsingKeyValues:keyValues OrderBy:(kQueryOrderBy)orderBy];
}
- (BOOL)deleteFromTableUsingKeys:(NSArray *)keys{
    return [[WGEasyManager shared]deleteFromTableWithModel:self UsingKeys:keys];
}

#pragma mark - 
- (BOOL)executeWithModel:(id )model executeBlock:(BOOL (^)(FMDatabase *db_))block{
    return [[WGEasyManager shared]executeWithModel:model executeBlock:block];
}

@end
