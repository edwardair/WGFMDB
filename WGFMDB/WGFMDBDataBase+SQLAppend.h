//
//  WGFMDBDataBase+SQLAppend.h
//  Sqlit
//
//  Created by RayMi on 15/6/26.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBase.h"
/**
 *  条件查询排序方式
 */
typedef NS_ENUM(NSInteger, kQueryOrderBy){
    kQueryOrderByDefault = 0,
    kQueryOrderByASC,
    kQueryOrderByDESC,
};

@interface WGFMDBDataBase (SQLAppend)
#pragma mark -
/**
 *  根据给定的数组，生成建表、插入、更新表的column组合字符串
    注: !!! column顺序是随机的
column顺序是按照model中的属性声明顺序，一旦表创建过，model中的顺序不能更改，也只能增加不能删减
 *  @param colmunModels @[WGFMDBColumnModel]
 *  @param hasType      column名后是否附带数据库类型
 *
 *  @return @"WGAuto_USERMOBILE TEXT,WGAuto_LOGIN BIT,..."
 */
- (NSString *)columnNames:(NSArray *)colmunModels appendColumnType:(BOOL)hasType;
/**
 *  根据数组，返回对应的 ":WGAuto_USER_ID,:WGAuto_MOBILE"字符串
 */
- (NSString *)placeHolderWithArray:(NSArray *)array;

#pragma mark -
/**
 *  建表sql
 *
 *  @param class 表对应的model类
 *
 */
- (NSString *)sql_getTableCreatStringWithOwnClass:(Class )class;

/**
 *  增加column sql
 *
 *  @param columnName 新增的column
 *  @param ownClass   表对应的model类
 *
 */
- (NSString *)sql_getAddANewColumnWithName:(NSString *)columnName OwnClass:(Class )ownClass;

/**
 *  插入
 *
 *  @param columnModels @[WGFMDBColumnModel]
 *  @param ownClass     表对应的model类
 *
 */
- (NSString *)sql_insertModelIntoTableWithColumns:(NSArray *)columnModels OwnClass:(Class )ownClass;
/**
 *  更新
 *
 *  @param columnModels @[WGFMDBColumnModel]
 *  @param where        select查询语句条件数组,
 *  @param ownClass     表对应的model类
 *
 */
- (NSString *)sql_updateModelIntoTableWithColumns:(NSArray *)columnModels
                                            Where:(NSDictionary *)where
                                         OwnClass:(Class )ownClass;
/**
 *  查询
 *
 *  @param columnModels @[WGFMDBColumnModel]
 *  @param where        select查询语句条件数组,
 *  @param ownClass     表对应的model类
 *
 */
- (NSString *)sql_selectModelFromTableWhere:(NSArray *)where
                                   OwnClass:(Class)ownClass
                                    OrderBy:(kQueryOrderBy)orderBy;
/**
 *  删除
 *
 *  @param columnModels @[WGFMDBColumnModel]
 *  @param where        select查询语句条件数组,
 *  @param ownClass     表对应的model类
 *
 */
- (NSString *)sql_deleteModelFromTableWhere:(NSArray *)where
                                         OwnClass:(Class )ownClass;
@end
