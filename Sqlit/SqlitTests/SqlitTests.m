//
//  SqlitTests.m
//  SqlitTests
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "WGFilePathModel.h"
#import "FMDB.h"

@interface SqlitTests : XCTestCase

@end

@implementation SqlitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testPath{
    NSString *path = NSHomeDirectory();//主目录
    NSLog(@"NSHomeDirectory:%@",path);
    NSString *userName = NSUserName();//与上面相同
    NSLog(@"userName:%@",userName);

    NSString *rootPath = NSHomeDirectoryForUser(userName);
    NSLog(@"NSHomeDirectoryForUser:%@",rootPath);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];//Documents目录
    NSLog(@"NSDocumentDirectory:%@",documentsDirectory);
}

- (void)testCreateFolder{
    
    WGFilePathModel *model = [WGFilePathModel modelWithType:Documents
                                            FileInDirectory:@"a"];
    
    
    model.fileName = @"test.png";
    
    NSLog(@"full:%@,dir:%@",model.fullPath,model.directoryPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:model.fullPath isDirectory:NULL]) {
        BOOL scuess = [[NSFileManager defaultManager]createFileAtPath:model.fullPath contents:[NSData data] attributes:NULL];
        if (scuess) {
            NSLog(@"创建成功");
        }else{
            NSLog(@"失败");
        }
    }
    
}


- (void)testCreateDB{
    
    WGFilePathModel *model = [WGFilePathModel modelWithType:Documents
                                            FileInDirectory:@"a"];
    
    
    model.fileName = @"test.db";
    NSLog(@"full:%@,dir:%@",model.fullPath,model.directoryPath);

    FMDatabase *database = [FMDatabase databaseWithPath:model.fullPath];
    
    if ([database open]) {
        [database close];

    }
    

    
}


@end
