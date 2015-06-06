//
//  WGFMDBColumnModel.h
//  Sqlit
//
//  Created by RayMi on 15/6/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  column相关的model
 */
@interface WGFMDBColumnModel : NSObject
+ (instancetype)modelWithName:(NSString *)columnName BridgeProtocol:(Protocol *)bridgeProtocol;
- (id)initWithName:(NSString *)columnName BridgeProtocol:(Protocol *)bridgeProtocol;

@property (nonatomic,copy) NSString *columnName;
@property (nonatomic,strong,readonly) Protocol *bridgeProtocol;

@property (nonatomic,copy,readonly) NSString *columnType;
@property (nonatomic,copy,readonly) NSString *placeHolder;
/**
 *  获取bridgeProtocol中所有定义的属性数组，
 *
 *  @param bridgeProtocol 桥接协议
 *  @param excpets        如果存在，则忽略数组中的名字
 *
 *  @return @[WGFMDBColumnModel]
 */
+ (NSArray *)getColumnsWithBridgeProtocol:(Protocol *)bridgeProtocol
                                   Except:(NSArray *)excpets;
@end
