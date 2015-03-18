//
//  WGFMDBDateBaseManager.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBDataBaseManager.h"
@interface WGFMDBDataBaseManager()

@property(nonatomic, strong) FMDatabaseQueue *writableQueue;
@property(nonatomic, strong) FMDatabaseQueue *readOnlyQueue;

@property (nonatomic,assign) BOOL isOpen;//是否已打开

@end



@implementation WGFMDBDataBaseManager
- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - outer methods
- (BOOL)open{
    
    @synchronized(self){
        
        if (_isOpen) {
            return YES;
        }
        
        //检测db文件是否存在
        BOOL isDBFileExist = [self isDBFileExist];
        
        if (!isDBFileExist) {
            //db文件不存在，需要创建
            
            
            
        }
        
        
    }
    
    
    
    
    
    return YES;
}


#pragma mark - privite methods
- (BOOL )isDBFileExist{
    return [[NSFileManager defaultManager] fileExistsAtPath:_pathModel.fullPath isDirectory:NULL];
}
@end
