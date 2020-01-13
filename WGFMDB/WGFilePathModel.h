//
//  WGFilePathModel.h
//  Sqlit
//
//  Created by RayMi on 15/3/18.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
//文件所处于的沙盒路径
typedef NS_ENUM(NSInteger, WGPathType) {
    kWGPathTypeEnableStart = 0,//验证 model是否支持设置的路径，不支持则报错
    
    //外部使用值
    kWGPathTypeHome,
    
    kWGPathTypeDocuments,
    kWGPathTypeLibrary,
    kWGPathTypeTmp,
    kWGPathTypeCaches,
    
    kWGPathTypeMainBoundle,

    //...后期可扩展
    
    kWGPathTypeEnableEnd,//验证 model是否支持设置的路径，不支持则报错
};

/**
 *  沙盒路径管理
 */
@interface WGFilePathModel : NSObject

/**
 *  初始化方法，需要传类型（确定沙盒目录）及所在自定义目录（确定文件处于的自定义目录）
 *
 *  @param type      WGPathType，不能为WGPathType定义范围外的值
 *  @param directory 文件所在路径，
                     可为nil：文件处于WGPathType对应文件夹下，
                     或者为：@"/img",@"img",@"img/",@"/img/"，文件夹不存在，则自动创建
 *
 */
+ (instancetype)modelWithType:(WGPathType )type FileInDirectory:(NSString *)directory;

/**
 *  文件所处的沙盒目录类型
 */
@property (nonatomic,assign) WGPathType type;
/**
 *  自定义目录名，see modelWithType:FileInDirectory:
 */
@property (nonatomic,copy) NSString *directory;
/**
 *  文件名，格式为： test.png
 */
@property (nonatomic,copy) NSString *fileName;


/**
 *  根据type 读取fileName对应的完整绝对路径
 */
@property (nonatomic,readonly) NSString *fullPath;
/**
 *  文件夹路径
 */
@property (nonatomic,readonly) NSString *directoryPath;


@end
