//
//  WGFMDBDataBase+SQLAppend.m
//  Sqlit
//
//  Created by RayMi on 15/6/26.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBase+SQLAppend.h"

@implementation WGFMDBDataBase (SQLAppend)
#pragma mark -
- (NSString *)columnNames:(NSArray *)colmunModels appendColumnType:(BOOL)hasType{
    NSMutableString *str = @"".mutableCopy;
    for (WGFMDBColumnModel *model_ in colmunModels) {
        if (hasType) {
            [str appendFormat:@"%@ %@ %@,",model_.columnName,model_.columnType,model_.especialColumnType];
        }else{
            [str appendFormat:@"%@ %@,",model_.columnName,model_.especialColumnType];
        }
    }
    if ([str hasSuffix:@","]) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    return str;
}

- (NSString *)columnNamesWithArray:(NSArray *)array{
    NSMutableString *columns = [NSMutableString string];
    for (int i = 0; i < array.count; i++) {
        [columns appendFormat:@"%@,",[array[i] columnName]];
    }
    
    if ([columns hasSuffix:@","]) {
        [columns deleteCharactersInRange:NSMakeRange(columns.length-1, 1)];
    }
    
    return columns;
}
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


#pragma mark - SQL 语句
#pragma mark - 获取建表SQL
- (NSString *)sql_getTableCreatStringWithOwnClass:(Class )class {
    NSString *sql = [NSString
                     stringWithFormat:
                     @"CREATE TABLE IF NOT EXISTS %@ (%@)", [class getTableName],
                     [self columnNames:[WGFMDBColumnModel
                                        getColumnsWithClass:class Excepts:nil]
                      appendColumnType:YES]];
    return sql;
}

#pragma mark - 增加column
- (NSString *)sql_getAddANewColumnWithName:(NSString *)columnName OwnClass:(Class )ownClass{
    WGFMDBColumnModel *model_ = [WGFMDBColumnModel modelWithName:columnName OwnClass:ownClass];
    return [NSString
            stringWithFormat:
            @"ALTER TABLE %@ ADD %@ %@ %@", [ownClass getTableName], columnName,
            model_.columnType,model_.especialColumnType];
}
#pragma mark - 插入model
- (NSString *)sql_insertModelIntoTableWithColumns:(NSArray *)columnModels OwnClass:(Class )ownClass{
    return [NSString
            stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@)  VALUES (%@)",
            [ownClass getTableName],
            [self columnNamesWithArray:columnModels],
            [self placeHolderWithArray:columnModels]
            ];
}
- (NSString *)sql_updateModelIntoTableWithColumns:(NSArray *)columnModels
                                            Where:(NSArray *)where
                                         OwnClass:(Class )ownClass{
    
    NSString *sql = [NSString
                     stringWithFormat:
                     @"UPDATE %@ SET __VALUES__ WHERE __CONDITIONS__",
                     [ownClass getTableName]];
    
    NSMutableString *values = @"".mutableCopy;
    for (int i = 0; i < columnModels.count; i++) {
        WGFMDBColumnModel *m = columnModels[i];
        [values appendFormat:@"%@ = %@ ",m.columnName,m.placeHolder];
        if (i<columnModels.count-1) {
            [values appendString:@","];
        }
    }
    
    NSMutableString *conditions = @"".mutableCopy;
    for (int i = 0; i < where.count; i++) {
        [conditions appendFormat:@"%@ = :%@",where[i],where[i]];
        if (i<where.count-1) {
            [conditions appendString:@" and "];
        }
    }

    sql = [sql stringByReplacingOccurrencesOfString:@"__VALUES__" withString:values];
    sql = [sql stringByReplacingOccurrencesOfString:@"__CONDITIONS__" withString:conditions];
    
    return sql;
}
- (NSString *)sql_selectModelFromTableWhere:(NSArray *)where
                                   OwnClass:(Class)ownClass
                                    OrderBy:(NSArray *)orderBy
                                     Offset:(int)offset
                                        Len:(int)len{
    NSString *sql = [NSString
                     stringWithFormat:
                     @"SELECT * FROM %@",
                     [ownClass getTableName]];
    
    for (int i = 0; i < where.count; i++) {
        if (i==0) {
            sql = [sql stringByAppendingString:@" WHERE "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = :%@",where[i],where[i]];
        if (i<where.count-1) {
            sql = [sql stringByAppendingString:@" and "];
        }
    }
    
    if (orderBy.count) {
        NSMutableString *by = @" ORDER BY ".mutableCopy;
        for (NSDictionary *dic in orderBy) {
            if ([dic.allValues.firstObject integerValue]==kQueryOrderByDESC) {
                [by appendFormat:@"%@ DESC,",dic.allKeys.firstObject];
            }else{
                [by appendFormat:@"%@,",dic.allKeys.firstObject];
            }
        }
        if ([by hasSuffix:@","]) {
            [by deleteCharactersInRange:NSMakeRange(by.length-1,1)];
        }
        
        sql = [sql stringByAppendingString:by];

    }

    //只有长度大于0的情况，SQL才能设置偏量、截取长度
    if (len>0) {
        sql = [sql stringByAppendingFormat:@" LIMIT %i",len];
        
        if (offset>0) {
            sql = [sql stringByAppendingFormat:@" OFFSET %i",offset];
        }
    }
    
    return sql;
}
- (NSString *)sql_deleteModelFromTableWhere:(NSArray *)where
                                   OwnClass:(Class )ownClass{
    NSString *sql = [NSString
                     stringWithFormat:
                     @"DELETE FROM %@",
                     [ownClass getTableName]];
    
    for (int i = 0; i < where.count; i++) {
        if (i==0) {
            sql = [sql stringByAppendingString:@" WHERE "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = :%@",where[i],where[i]];
        if (i<where.count-1) {
            sql = [sql stringByAppendingString:@" and "];
        }
    }
    
    return sql;
}
@end
