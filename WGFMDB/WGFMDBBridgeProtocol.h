//
//  WGFMDBBridgeProtocol.h
//  Sqlit
//
//  Created by RayMi on 15/6/4.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  如果属性名以  以下定义的字段为开头，表明表中column对应的类型需要加上这些修饰
    为防止可能存在的命名冲突，在前后增加WG_字段
 */
#define PRIMARY_KEY @"_WG_PRIMARY KEY_WG_"
//...以后增加其他定义


/**
 *  此Protocol方法名直接对应需要存入数据库表的column名
    当建表、插入整个model、更新整个model、获取整个model时，使用此Protocol定义的方法名来存取
    注意：方法名同时对应于项目中的各个model中的属性名，
    此Protocol仅作为哪些字段需要跟数据库来交互的一个桥接，不作为定义新属性使用
 */
@protocol WGFMDBBridgeProtocol <NSObject>
//@property (nonatomic,copy) NSString *WG_PRIMARY_KEY_WG_PROPERTY_NAME;
@end
