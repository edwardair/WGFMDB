//
//  AppDelegate.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "AppDelegate.h"
#import "WGFMDB.h"

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

@property (nonatomic,copy) NSString *myID;
@property (nonatomic,copy) NSString *otherID;


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
    m.aaa = 16;
    m.WGAuto_MOBILEPHONE = @"13888887777";
//    m.WGAuto_PASSWORD = @"ggggg";
//    m.WGAuto_FULLNAME = @"全名";
    m.WGAuto_IDKEY = @13;
    m.myID = @"12";
    m.otherID = @"34";
    
    [LocalUserInfoModel registerTableAtPath:^WGFilePathModel *{
        WGFilePathModel *filePathModel = [WGFilePathModel modelWithType:kWGPathTypeDocuments FileInDirectory:@"test"];
        filePathModel.fileName = @"user.db";
        return filePathModel;
    }];
    
    //插入
//    [m insertIntoTable];
//    [m insertIntoTable];
//    [m insertIntoTable];

    //更新
//    [m updateIntoTableWhere:@[WGPNAME(WGAuto_MOBILEPHONE)] OnlyUpdateThese:@[WGPNAME(WGAuto_PASSWORD)]];
    
    //查找
//    NSArray *a = [LocalUserInfoModel selectFromTableUsingKeyValues:@{WGPNAME(WGAuto_MOBILEPHONE):m.WGAuto_MOBILEPHONE} OrderBy:@[@{WGPNAME(WGAuto_IDKEY):@(kQueryOrderByDESC)}] Offset:1 Len:-1];
//    WGLogValue(a.count);
//    
//    //获取第一个
//    LocalUserInfoModel* m1 = [LocalUserInfoModel selectLastFromTableUsingKeyValues:@{WGPNAME(WGAuto_MOBILEPHONE):m.WGAuto_MOBILEPHONE} OrderBy:nil];
//    
//    [LocalUserInfoModel deleteFromTableUsingKeyValues:@{WGPNAME(WGAuto_MOBILEPHONE):m1.WGAuto_MOBILEPHONE,WGPNAME(WGAuto_IDKEY):@12}];
    
    //自定义SQL语句实现方式
    BOOL scuess = [LocalUserInfoModel executeWithBlock:^BOOL(FMDatabase *db_) {
        NSString *sql = @"select * from LocalUserInfoModel where myID = ? and otherID = ? LIMIT 3 OFFSET 2";
        FMResultSet *rest = [db_ executeQuery:sql,@12,@34];
        
        while ([rest next]) {
            LocalUserInfoModel *model = [LocalUserInfoModel modelWithResultSet:rest ];
            [rest close];

            return YES;
        }
        
        
        return NO;
        
    }];
    
    NSArray *all = [LocalUserInfoModel allTableModels];
    WGLogValue(all.count);
}



@end
