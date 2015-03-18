//
//  WGFilePathModel.m
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#define Component @"/"

#import "WGFilePathModel.h"

@interface WGFilePathModel()

@property (nonatomic,assign) WGPathType type;

/**
 *  自定义目录名，可为nil
 */
@property (nonatomic,copy) NSString *directory;
/**
 *  目录是否可用
    如果目录创建失败，或者对应的目录并不是 “文件夹”类型，则为NO
 */
@property (nonatomic,assign) BOOL isDirectoryUnable;//
@end



@implementation WGFilePathModel
+ (instancetype)modelWithType:(WGPathType)type FileInDirectory:(NSString *)directory{
    return [[[self class]alloc]initWithType:type FileInDirectory:directory];
}

- (instancetype)initWithType:(WGPathType )type FileInDirectory:(NSString *)directory{

    //检查 type 是否有效
    [self checkTypeUseable:type];
    
    self = [super init];
    if (self) {
        _type = type;
        _directory = directory;
        _isDirectoryUnable = YES;

        //如果 directory存在，需要检查文件夹是否存在，不存在，则创建
        BOOL isDirectory;
        BOOL exist = [[NSFileManager defaultManager]fileExistsAtPath:self.directoryPath isDirectory:&isDirectory];
        
        if (exist && !isDirectory) {
            NSLog(@"将要创建的目录名已存在，但类型不是文件夹，无法创建目录");
            _isDirectoryUnable = NO;
        }
        else{
            //创建目录
            NSError *error;
            if (![[NSFileManager defaultManager]createDirectoryAtPath:self.directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                _isDirectoryUnable = NO;

                NSLog(@"%s:创建目录失败,%@",__FUNCTION__,error.description);
            }else{
                _isDirectoryUnable = YES;//创建目录成功，置为YES
            }
        }

        
    }
    return self;
}

#pragma mark - setter
- (void)setFileName:(NSString *)fileName{
    
    //验证 文件名是否合法
    if (!fileName) {
        NSLog(@"ERROR:%s,文件名不能为空",__FUNCTION__);
        return;
    }
    
    _fileName = fileName;
    
}


#pragma mark - getter
- (NSString *)fullPath{
    if (!_isDirectoryUnable) {
        NSLog(@"%s:目录不存在或不可用",__FUNCTION__);
        return nil;
    }
    
    return [self.directoryPath
            stringByAppendingPathComponent:_fileName];
}
- (NSString *)directoryPath{
    if (!_isDirectoryUnable) {
        NSLog(@"%s:目录不存在或不可用",__FUNCTION__);
        return nil;
    }

    return [[self systemDirectoryPathByType:_type] stringByAppendingPathComponent:_directory];
}


#pragma mark - 根据type获取对应的 沙盒中的系统目录
- (NSString *)systemDirectoryPathByType:(WGPathType)type {
    [self checkTypeUseable:type];
    
    switch (type) {
        case Home:
            return NSHomeDirectory();
        case Documents:
            return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        case Library:
            return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        case Tmp:
            return NSTemporaryDirectory();
            case Caches:
            return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        default:{
            NSLog(@"WARN:WGPathType定义，但未实现具体路径！！");
        }
            return @"";//返回空值
    }
}


#pragma mark - 错误检测，检测type是否为当前封装所支持
- (void)checkTypeUseable:(WGPathType )type{
    if (type <= WGPathEnableStart || type >= WGPathEnableEnd) {
        assert(@"WGFilePathModel 暂不支持此type，可以自行扩展");
    }
}

@end
