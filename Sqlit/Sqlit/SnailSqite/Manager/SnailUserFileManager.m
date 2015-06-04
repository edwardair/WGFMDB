//
//  SnailUserInfoManager.m
//  Snail
//
//  Created by RayMi on 15/4/4.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "SnailUserFileManager.h"

@implementation SnailUserFileManager
+ (instancetype)shared{
    static id stroage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stroage = [[[self class]alloc]init];
    });
    return stroage;
}

- (id)init{
    if ((self = [super init])) {
        _dao = [UserFileDao dao];
    }
    return self;
}
@end
