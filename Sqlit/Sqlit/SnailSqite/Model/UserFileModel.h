//
//  UserFileModel.h
//  Snail
//
//  Created by 丝瓜&冬瓜 on 15/4/5.
//  Copyright (c) 2015年 丝瓜&冬瓜. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserFileModel : NSObject

@property (nonatomic,copy) NSString *WGAuto_fileName;//  文件名
@property (nonatomic,copy) NSString *WGAuto_filePath;//  文件路径
@property (nonatomic,assign) NSTimeInterval WGAuto_downloadTimestamp;//  文件下载时间
@property (nonatomic,assign) NSTimeInterval WGAuto_lastReadTimestamp;//  上次文件读取时间，WGAuto_didRead==NO时为0
@property (nonatomic,assign) int WGAuto_fileSize;//  文件大小
@property (nonatomic,assign) BOOL WGAuto_didRead;//  是否读过

@property (nonatomic,assign) NSInteger WGAuto_identifier;//只在读取时，从数据库中读取，用于在更新数据库时，识别model
@end
