//
//  WGBaseDao.m
//  Sqlit
//
//  Created by 丝瓜&冬瓜 on 15/3/19.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGBaseDao.h"

@implementation WGBaseDao

#pragma mark - WGBaseDaoProtocol optional
+ (instancetype)dao{

    if (![[self class]conformsToProtocol:@protocol(WGBaseDaoProtocol)]) {
        NSAssert(NO, @"需要子类实现协议");
    }
    
    static id dao;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dao = [[[self class]alloc]initWithDataBase:nil];
    });
    
    return dao;
}

#pragma mark - WGBaseDaoProtocol required

- (instancetype)initWithDataBase:(id )staticDataBase{
    self = [super init];
    if (self) {
        _dataBase = staticDataBase;
    }
    return self;
}


+ (BOOL)createTableInDatabase:(FMDatabase *)db{
    
    NSAssert(NO, @"子类实现");
    
    return NO;
}


#pragma mark - 


@end
