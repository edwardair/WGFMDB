//
//  AppDelegate.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "AppDelegate.h"
#import "WGFMDB.h"
#import "WGEasyManager.h"

@interface AA : NSObject
@property (nonatomic,copy) NSString *test;
@end
@implementation AA
@end

@interface LocalUserInfoModel : NSObject<WGEasyEspecialColumnTypeProtocol>
@property (nonatomic,assign) int aaa;
//通用
@property (nonatomic,copy) NSString *WGAuto_MOBILEPHONE;
@property (nonatomic,copy) NSString *WGAuto_FULLNAME;

@property (nonatomic,strong) NSNumber *WGAuto_IDKEY;
@property (nonatomic,copy) NSString *WGAuto_PASSWORD;

@end
@implementation LocalUserInfoModel
//+ (NSDictionary *)especialColumnType{
//    return @{
//             WGPNAME(WGAuto_IDKEY):@"PRIMARY KEY"};
//}
//+ (NSArray *)excpets{
//    return nil;
//}
@end

@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self test];
    
    return YES;
}

- (void)test{
    LocalUserInfoModel *m = [[LocalUserInfoModel alloc]init];
    m.aaa = 11;
    m.WGAuto_MOBILEPHONE = @"13888887777";
    m.WGAuto_PASSWORD = @"123456";
//    m.WGAuto_FULLNAME = @"全名";
    m.WGAuto_IDKEY = @12;

    [LocalUserInfoModel registerTableAtPath:^WGFilePathModel *{
        WGFilePathModel *filePathModel = [WGFilePathModel modelWithType:kWGPathTypeDocuments FileInDirectory:@"test"];
        filePathModel.fileName = @"user.db";
        return filePathModel;
    }];
    
    [m insertIntoTable];
    
    m.WGAuto_PASSWORD = @"654321";
    [m updateIntoTableWhere:@{WGPNAME(WGAuto_MOBILEPHONE):@"13888887777"}];
    
}
//- (void)test{
//    
//    if ([[[SnailUserInfoManager shared] dao] openWithUserMobile:@"13888888888"]) {
//        
//        LocalUserInfoModel *model = [[LocalUserInfoModel alloc]init];
//        model.WGAuto_MOBILEPHONE = @"138120000";
//        model.WGAuto_PASSWORD = @"123456";
////        model.WGAuto_FULLNAME = @"全名";
//        model.WGAuto_IDKEY = @180;
////        model.WGAuto_HEADPORTRAIT = @"无头像";
//        model.aaa = 101;
//        
//        [[[SnailUserInfoManager shared] dao] asyncInsertLocalUserInfo:model];
//        
//    }else{
//        WGLogError(@"开库失败");
//    }
//    
//}



@end
