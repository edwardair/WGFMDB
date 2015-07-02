//
//  WGEasyEspecialColumnType.h
//  Sqlit
//
//  Created by RayMi on 15/6/26.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WGEasyEspecialColumnTypeProtocol 
@optional
/**
 *  定制column的特殊类型，如 PRMARY KEY,FOREIGN KEY,etc...
 *
 *  @return @{@"属性名":@"PRMARY KEY"}
 */
+ (NSDictionary *)especialColumnType;
/**
 *  全局过滤不需要存入数据库中的属性字段
 *  @return model中不需要存入数据库的属性名数组
 */
+ (NSArray *)excepts;
@end
