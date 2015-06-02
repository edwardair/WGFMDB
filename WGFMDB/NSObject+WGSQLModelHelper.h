//
//  NSObject+WGSQLModelHelper.h
//  Sqlit
//
//  Created by RayMi on 15/3/20.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

/**
 *  间接获取Model的属性名字，通过Xcode的代码补全功能，对属性名称进行提示
 *
 *  @param sel 属性的get方法名
 *
 *  @return 方法名，也是属性名
 */
#define WGPNAME(sel) [NSObject getPropertyNameWitmMethod:@selector(sel)]

/**
 *  对于Model类型的对象，转化其属性名为NSString，数据库字段名
 */
@interface NSObject (WGSQLModelHelper)

+ (NSString *)getPropertyNameWitmMethod:(SEL )selector;

+ (instancetype)modelWithResultSet:(FMResultSet*)rs;

@end


#pragma mark - NSString category
@interface NSString (BigPrefix)
/**
 *  字符串第一个字母改为大写
 */
- (NSString *)uppercasePrefixString;
@end


