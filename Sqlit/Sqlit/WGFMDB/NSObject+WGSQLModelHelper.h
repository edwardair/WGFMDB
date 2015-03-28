//
//  NSObject+WGSQLModelHelper.h
//  Sqlit
//
//  Created by RayMi on 15/3/20.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 *  对于Model类型的对象，转化其属性名为NSString，数据库字段名
 */
@interface NSObject (WGSQLModelHelper)
- (NSString *)getPropertyName:(const char *)property;
@end
