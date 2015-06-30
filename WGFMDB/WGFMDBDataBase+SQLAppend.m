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
                     @"CREATE TABLE IF NOT EXISTS %@ (%@)", NSStringFromClass(class),
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
            @"ALTER TABLE %@ ADD %@ %@ %@", NSStringFromClass(ownClass), columnName,
            model_.columnType,model_.especialColumnType];
}
#pragma mark - 插入model
- (NSString *)sql_insertModelIntoTableWithColumns:(NSArray *)columnModels OwnClass:(Class )ownClass{
    return [NSString
            stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@)  VALUES (%@)",
            NSStringFromClass(ownClass),
            [self columnNamesWithArray:columnModels],
            [self placeHolderWithArray:columnModels]
            ];
}
- (NSString *)sql_updateModelIntoTableWithColumns:(NSArray *)columnModels
                                            Where:(NSDictionary *)where
                                         OwnClass:(Class )ownClass{
    
    NSString *sql = [NSString
                     stringWithFormat:
                     @"UPDATE %@ SET (%@) VALUES (%@)",
                     NSStringFromClass(ownClass),
                     [self columnNamesWithArray:columnModels],
                     [self placeHolderWithArray:columnModels]];
    
    for (int i = 0; i < where.count; i++) {
        if (i==0) {
            sql = [sql stringByAppendingString:@" WHERE "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = ?",where[i]];
        if (i<where.count-1) {
            sql = [sql stringByAppendingString:@","];
        }
    }
    
    return sql;
}
- (NSString *)sql_selectModelFromTableWhere:(NSArray *)where
                                   OwnClass:(Class)ownClass
                                    OrderBy:(kQueryOrderBy)orderBy{
    NSString *sql = [NSString
                     stringWithFormat:
                     @"SELECT * FROM %@",
                     NSStringFromClass(ownClass)];
    
    for (int i = 0; i < where.count; i++) {
        if (i==0) {
            sql = [sql stringByAppendingString:@" WHERE "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = ?",where[i]];
        if (i<where.count-1) {
            sql = [sql stringByAppendingString:@","];
        }
    }
    
    switch (orderBy) {
        case kQueryOrderByDefault: {
            break;
        }
        case kQueryOrderByASC: {
            sql = [sql stringByAppendingString:@" ORDER BY ASC"];
            break;
        }
        case kQueryOrderByDESC: {
            sql = [sql stringByAppendingString:@" ORDER BY DESC"];
            break;
        }
        default: {
            break;
        }
    }
    
    return sql;
}
- (NSString *)sql_deleteModelFromTableWhere:(NSArray *)where
                                   OwnClass:(Class )ownClass{
    NSString *sql = [NSString
                     stringWithFormat:
                     @"DELETE FROM %@",
                     NSStringFromClass(ownClass)];
    
    for (int i = 0; i < where.count; i++) {
        if (i==0) {
            sql = [sql stringByAppendingString:@" WHERE "];
        }
        sql = [sql stringByAppendingFormat:@"%@ = ?",where[i]];
        if (i<where.count-1) {
            sql = [sql stringByAppendingString:@","];
        }
    }
    
    return sql;
}
@end
