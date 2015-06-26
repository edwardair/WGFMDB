////
////  LocalUserInfoModel.m
////  Snail
////
////  Created by RayMi on 15/4/4.
////  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
////
//
//#import "LocalUserInfoModel.h"
//
//@implementation LocalUserInfoModel
//
//- (id)init{
//    if ((self = [super init])) {
//        
//        //时间戳  在初始化时定死，不可更改
//        _WGAuto_LastLoginTimestamp = [[NSDate date] timeIntervalSince1970];
//
//        //版本号 定制
//        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
//        _WGAuto_LastLoginVersion = [infoDic objectForKey:@"CFBundleVersion"];
//
//    }
//    return self;
//}
//
//@end
