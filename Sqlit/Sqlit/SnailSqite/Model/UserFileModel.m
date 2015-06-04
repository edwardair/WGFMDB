//
//  UserFileModel.m
//  Snail
//
//  Created by 丝瓜&冬瓜 on 15/4/5.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import "UserFileModel.h"

@implementation UserFileModel
- (id)init{
    if ((self = [super init])) {
        
        //时间戳  在初始化时赋值，可外部修改，也可直接使用
        _WGAuto_downloadTimestamp = [[NSDate date] timeIntervalSince1970];
        
    }
    return self;
}

@end
