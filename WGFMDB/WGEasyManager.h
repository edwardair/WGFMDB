//
//  WGEasyManager.h
//  Sqlit
//
//  Created by RayMi on 15/6/25.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGFilePathModel.h"
#import "WGEasyEspecialColumnTypeProtocol.h"
#import "WGFMDBDataBase.h"
#import "WGFMDBDataBase+SQLAppend.h"


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
- (BOOL)insertIntoTable;
/**
 *  将model存入数据库
 *
 *  @param keys 对于keys中列出的属性名称将不存入数据库中
 *
 *  @return 成功、失败
 */
- (BOOL)insertIntoTableExceptKeys:(NSArray *)keys;
/**
 *  更新数据库，将把[model modelValue]中所有值更新进数据库
 *
 *  @param keyValues 查询条件
 *
 *  @return 成功、失败
 */
- (BOOL)updateIntoTableWhere:(NSDictionary *)keyValues;
/**
 *  更新数据库
 *
 *  @param keyValues 查询条件
 *  @param keys      只针对keys中包含的字段进行更新
 *
 *  @return 成功、失败
 */
- (BOOL)updateIntoTableWhere:(NSDictionary *)keyValues OnlyUpdateThese:(NSArray *)keys;
/**
 *  条件查询
 *
 *  @param keys model的属性名称数组，select条件查询需要
 *
 *  @return 成功、失败
 */
+ (NSArray *)selectFromTableUsingKeyValues:(NSDictionary *)keyValues OrderBy:(kQueryOrderBy )orderBy;
/**
 *  将keys条件查询得到的数据从表中移除
 *
 *  @param keys model的属性名称数组，select条件查询需要
 *
 *  @return 成功、失败
 */
- (BOOL)deleteFromTableUsingKeys:(NSArray *)keys;

#pragma mark - 未支持的sql操作暂时使用原生sql语句
- (BOOL)executeWithModel:(id )model executeBlock:(BOOL (^)(FMDatabase *db_))block;
@end

