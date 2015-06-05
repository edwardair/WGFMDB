//
//  LocalUserInfoModel.h
//  Snail
//
//  Created by RayMi on 15/4/4.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WGCategory/WGDefines.h>

@protocol LocalUserInfoModelBridgeProtocol <NSObject>
@property (nonatomic,copy) NSString *WGAuto_MOBILEPHONE;//  手机号
@property (nonatomic,copy) NSString *WGAuto_PASSWORD;//  密码
@property (nonatomic,copy) NSString *WGAuto_FULLNAME;//  姓名
@property (nonatomic,strong) NSNumber *WGAuto_IDKEY;// ID
@property (nonatomic,copy) NSString *WGAuto_HEADPORTRAIT;//  头像
@property (nonatomic,assign) int a;

@property (nonatomic,assign) int B;
@property (nonatomic,assign) int c;

- (NSString *)test;
@end

@interface LocalUserInfoModel : NSObject
//通用
@property (nonatomic,copy) NSString *WGAuto_MOBILEPHONE;//  手机号
@property (nonatomic,copy) NSString *WGAuto_PASSWORD;//  密码
@property (nonatomic,copy) NSString *WGAuto_FULLNAME;//  姓名
@property (nonatomic,strong) NSNumber *WGAuto_IDKEY;// ID
@property (nonatomic,copy) NSString *WGAuto_HEADPORTRAIT;//  头像
@property (nonatomic,copy) NSString *WGAuto_SEX;//  性别
@property (nonatomic,copy) NSString *WGAuto_AGE;//  年龄
@property (nonatomic,copy) NSString *WGAuto_BALANCE;// 余额 /
@property (nonatomic,copy) NSString *WGAuto_TYPES;// 注册类别
@property (nonatomic,copy) NSString *WGAuto_SCHOOL;//  学校
@property (nonatomic,copy) NSString *WGAuto_MYINVITECODE;// 邀请码 
@property (nonatomic,copy) NSString *WGAuto_STATES;// 审核状态
@property (nonatomic,copy) NSString *WGAuto_CITYS;// 审核状态

//sutdent
@property (nonatomic,copy) NSString *WGAuto_GRADE;//  年级

//teacher
@property (nonatomic,copy) NSString *WGAuto_TEACHINGSUBJECTS;// 授课科目
@property (nonatomic,copy) NSString *WGAuto_TEACHERSTYPES;// 教师类型
@property (nonatomic,copy) NSString *WGAuto_INTRODUCTION;// 个人简介
@property (nonatomic,copy) NSString *WGAuto_AUTHENTICATION;//认证状态
//local
@property (nonatomic,readonly) NSTimeInterval WGAuto_LastLoginTimestamp;//  最近登录时间
@property (nonatomic,readonly) NSString *WGAuto_LastLoginVersion;//  最近登录版本号

@property (nonatomic,assign) BOOL WGAuto_IsLogin;//是否登录状态

//state
@property (nonatomic,copy) NSString *WGAuto_IOSSTATES;
@end
