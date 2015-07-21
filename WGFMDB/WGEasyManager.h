//
//  WGEasyManager.h
//  Sqlit
//
//  Created by RayMi on 15/6/25.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGFilePathModel.h"
#import "WGFMDBDataBase.h"
#import "WGFMDBDataBase+SQLAppend.h"
#import "WGEasyEspecialColumnTypeProtocol.h"


@interface NSObject(WGEasyManager)
/**
*  开库、建表、增加表中没有的字段都会在此时完成，多个表时需要多次调用此方法
*
*  @param pathModel 数据库文件路径model，默认为Tmp
                    注：以下相同不相同是相对于内部封装而言的，使用时无需特殊处理
                    1、当路径相同，class相同或者不相同，重复开库无效，但会相应检测table及column是否存在
                    2、当路径不同，class不相同，将正常开库，需要手动调用resignTable
                    3、当路径不同，class相同，将上一个class对应的库调用resignTable闭库，再正常开库，需要手动调用resignTable

*
*  @return 成功、失败
*/
+ (BOOL)registerTableAtPath:(WGFilePathModel *(^)())pathModelBlock;
/**
 *  Class调用一次registerTableAtPath:，在不使用此数据库时，需要相应调用一次resignTable
    用于检测是否可以将某个db闭库
 *
 *  @return 成功、失败
 */
+ (BOOL)resignTable;

/**
 *  将model存入数据库
 *
 *  @return 成功、失败
 */
- (BOOL)executeInsertIntoTable;
/**
 *  将model存入数据库
 *
 *  @param keys 对于keys中列出的属性名称将不存入数据库中
 *
 *  @return 成功、失败
 */
- (BOOL)executeInsertIntoTableExceptKeys:(NSArray *)keys;
/**
 *  更新数据库，将把[model modelValue]中所有值更新进数据库
 *  注：如果model中的属性，比如NSString* ==nil,则效果为将此属性对应的column的值修改为空
 *  @param keys 查询条件
 *
 *  @return 成功、失败
 */
- (BOOL)executeUpdateIntoTableWhere:(NSArray *)keys;
/**
 *  更新数据库
 *
 *  @param keys 查询条件
 *  @param theseKeys      只针对these中包含的字段进行更新
 *
 *  @return 成功、失败
 */
- (BOOL)executeUpdateIntoTableWhere:(NSArray *)keys OnlyUpdateThese:(NSArray *)theseKeys;

/**
 *  条件查询，所有以下扩展的条件查询都基于此方法
 *
 *  @param keyValues 查询条件的键值对
 *  @param orderBy   @[ @{属性名称:@(kQueryOrderBy)} ]，默认可传nil
 *  @param offset     [(offset<=0) => (从0开始)]
 *  @param len       len<=0时，offset无效
 *
 *  @return @[] if not select
 */
+ (NSArray *)executeSelectFromTableUsingKeyValues:(NSDictionary *)keyValues
                                   OrderBy:(NSArray *)orderBy
                                    Offset:(int)offset
                                       Len:(int)len;

/**
 *  条件查询
 *
 *  @param keys model的属性名称数组，select条件查询需要
 *
 *  @return 成功、失败
 */
+ (NSArray *)executeSelectFromTableUsingKeyValues:(NSDictionary *)keyValues
                                          OrderBy:(NSArray *)orderBy;

/**
 *  same as "select * from tablename"
 *
 *  @return @[Models]
 */
+ (NSArray *)allTableModels;

/**
 *  按顺序获取第一个符合条件的model
 *
 *  @param keyValues 条件查询
 *  @param orderBy   排序方式
 *
 *  @return @[] if not select
 */
+ (instancetype)firstModelUsingKeyValues:(NSDictionary *)keyValues
                                 OrderBy:(NSArray *)orderBy;

/**
 *  按顺序获取第后一个符合条件的model
 *
 *  @param keyValues 条件查询
 *  @param orderBy   排序方式
 *
 *  @return @[] if not select
 */
+ (instancetype)lastModelUsingKeyValues:(NSDictionary *)keyValues
                                OrderBy:(NSArray *)orderBy;

/**
 *  将keys条件查询得到的数据从表中移除
 *
 *  @param keyValues 条件查询
 *
 *  @return 成功、失败
 */
+ (BOOL)executeDeleteFromTableUsingKeyValues:(NSDictionary *)keyValues;

#pragma mark - 未支持的sql操作暂时使用原生sql语句
+ (BOOL)executeWithBlock:(BOOL (^)(FMDatabase *db_))block;
@end

