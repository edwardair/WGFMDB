//
//  NSObject+WGSQLModelHelper.h
//  Sqlit
//
//  Created by RayMi on 15/3/20.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMResultSet.h>

/**
 *  数据类型
 */
@interface WGSQLModelHelper : NSObject
//TODO: 后期扩展支持字段...
/**
 *  如果属性名以  "_WG_**"结尾，在转化column类型时需要去掉
 */
@property NSString *TEXT_WG_String;
@property int INT;
@property NSTimeInterval FLOAT_WG_TimeInterval;
@property NSInteger INT_WG_Integer;
@property float FLOAT;
@property double DOUBLE;
@property NSNumber *TEXT_WG_Number;
@property BOOL BIT;
@end

/**
 *  间接获取Model的属性名字，通过Xcode的代码补全功能，对属性名称进行提示
 *
 *  @param sel 属性的get方法名
 *
 *  @return 方法名，也是属性名
 */
#define WGPNAME(sel) [NSObject getPropertyNameWitmMethod:@selector(sel)]


#pragma mark -
/**
 *  对于Model类型的对象，转化其属性名为NSString，数据库字段名
 */
@interface NSObject (WGSQLModelHelper)

+ (NSString *)getPropertyNameWitmMethod:(SEL )selector;

+ (instancetype)modelWithResultSet:(FMResultSet*)rs;

/**
 *  获取protocol的属性名对应的数据库类型名
 *
 *  @param pName    protocol中定义的get方法、或者属性名
 *  @param protocol model存入数据库的桥接协议
 *
 *  @return 存数据库中的数据库cloumn基本类型
 */
+ (NSString *)getColumnTypeWithPropertyName:(NSString *)pName BridgeProtocol:(Protocol *)protocol;

/**
 *  获取所有column字段名
 *
 *  @param bridgeProtocol model存入数据库的桥接协议
 *  @param modelClass     model的Class
 *  @param excpets        数组中的除外，用于update、insert时
 *  @param hasColumnType  建表时需要，附带column的类型，如  TEXT、BIT等数据库类型
 *
 *  @return <#return value description#>
 */
+ (NSString *)getColumnsWithBridgeProtocol:(Protocol *)bridgeProtocol
                                ModelClass:(Class )modelClass
                                    Except:(NSArray *)excpets
                            AppendWithType:(BOOL)hasColumnType;

#if DEBUG
/**
 *  DEBUG测试使用，打印出WGSQLModelHelper中定义的所有属性名对应的property_getAttributes
 */
+ (void)DEBUG_ShowAllColumnTypesInWGSQLModelHelper;
#endif

@end


#pragma mark - NSString category
@interface NSString (BigPrefix)
/**
 *  字符串第一个字母改为大写
 */
- (NSString *)uppercasePrefixString;
@end


