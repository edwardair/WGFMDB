//
//  WGBaseDao.m
//  Sqlit
//
//  Created by 丝瓜&冬瓜 on 15/3/19.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBBaseDao.h"
#import "WGDefines.h"

@interface WGFMDBBaseDao()
@property (nonatomic,strong) WGFMDBDataBase *dataBase;
@end
@implementation WGFMDBBaseDao

#pragma mark - WGFMDBBaseDaoProtocol required
- (void)setupDataBase{

}

#pragma mark - WGFMDBBaseDaoProtocol optional
+ (instancetype)dao{
    static id dao;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dao = [[[self class]alloc]init];
    });
    
    return dao;
}

- (BOOL)open{
    return [self.dataBase open];
}

- (void)setupFilePathModel{
    WGLogMsg(@"如需设置默认WGFilePathModel，子类需继承并设置");
}


#pragma mark -  Iniaiailzer
- (id)init{
    if ((self = [super init])) {
        [self setupDataBase];
        [self setupFilePathModel];
    }
    return self;
}

#pragma mark - selector
- (void)closeAll{
    [self.dataBase closeAll];
}
- (void)removeDBFile{
    [self.dataBase removeDBFile];
}
- (void)closeAndRemoveDBFile{
    [self.dataBase closeAll];
    [self.dataBase removeDBFile];
}
- (void)setupDataBase:(id)dataBase{
    self.dataBase = dataBase;
}
- (void)setupFilePathModelWithType:(WGPathType)type
                   FileInDirectory:(NSString *)directory
                          FileName:(NSString *)fileName {
    WGFilePathModel *filePathModel = [WGFilePathModel modelWithType:type FileInDirectory:directory];
    filePathModel.fileName = fileName;
    self.dataBase.pathModel = filePathModel;
}


#pragma mark - getter
- (FMDatabaseQueue *)readOnlyQueue{
    return self.dataBase.readonlyQueue;
}
- (FMDatabaseQueue *)writableQueue{
    return self.dataBase.writeableQueue;
}

- (WGFMDBDataBase *)dataBase{
    if (!_dataBase) {
//        _dataBase = [WGFMDBDataBase shared];
    }
    return _dataBase;
}

#pragma mark - SQL语句封装


@end
