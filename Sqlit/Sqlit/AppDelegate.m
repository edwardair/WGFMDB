//
//  AppDelegate.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "AppDelegate.h"
#import "WGFMDB.h"
#import "SnailUserInfoManager.h"

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
    
    if ([[[SnailUserInfoManager shared] dao] openWithUserMobile:@"13888888888"]) {
        
        LocalUserInfoModel *model = [[LocalUserInfoModel alloc]init];
        model.WGAuto_MOBILEPHONE = @"138120000";
        model.WGAuto_PASSWORD = @"123456";
//        model.WGAuto_FULLNAME = @"全名";
        model.WGAuto_IDKEY = @180;
//        model.WGAuto_HEADPORTRAIT = @"无头像";
        model.aaa = 101;
        
        [[[SnailUserInfoManager shared] dao] asyncInsertLocalUserInfo:model];
        
    }else{
        WGLogError(@"开库失败");
    }
    
}



@end
