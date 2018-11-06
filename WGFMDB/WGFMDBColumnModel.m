//
//  WGFMDBColumnModel.m
//  Sqlit
//
//  Created by RayMi on 15/6/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBColumnModel.h"
#import <objc/runtime.h>
#import <WGKit/WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"
#import "WGEasyEspecialColumnTypeProtocol.h"

#pragma mark - WGSQL支持的属性转column类型定义
@interface WGSQLModelHelper : NSObject
//TODO: 后期扩展支持字段...
/**
 *  如果属性名以  "_WG_**"结尾，在转化column类型时需要去掉
 */
@property NSString *TEXT$String;
@property NSNumber *TEXT$Number;

@property int INT;
@property NSInteger INT$Integer;

@property float FLOAT;
@property NSTimeInterval FLOAT$TimeInterval;

@property double DOUBLE;

@property BOOL BIT;

@end

@implementation WGSQLModelHelper
#if DEBUG
+ (void)DEBUG_ShowAllColumnTypesInWGSQLModelHelper{
    u_int outCount;
    objc_property_t *properties  = class_copyPropertyList([WGSQLModelHelper class], &outCount);
    
    for (u_int i = 0; i < outCount; i++) {
        const char *attributes_name = property_getAttributes(properties[i]);
        const char *property_name = property_getName(properties[i]);
        
        WGLogFormatValue(@"\n属性名：%s\nAttributes:%s",property_name,attributes_name);
    }
    
    free(properties);
}

+ (void)load{
    WGLogMsg(@"当前编译环境为DEBUG，将会打印WGSQLModel所支持的属性类型");
    [self DEBUG_ShowAllColumnTypesInWGSQLModelHelper];
}
#endif

#pragma mark - 数据库column相关
+ (objc_property_t )propertyInClass:(Class )class WithName:(NSString *)pName{
    u_int outCount;
    objc_property_t *properties  = class_copyPropertyList(class, &outCount);
    objc_property_t p = NULL;
    for (u_int i = 0; i < outCount; i++) {
        const char *tmp = property_getName(properties[i]);
        NSString *p_ = [NSString stringWithFormat:@"%s",tmp];
        
        if ([pName isEqualToString:p_]) {
            p = properties[i];
            break;
        }
    }
    
    free(properties);
    return p;
}
/**
 *  截取const char*，以第一个','为前缀的字符串
 *
 *  @param property_attributes
 *
 *  @return 需要调用者调用 free(char *)
 */
+ (char *)propertyAttributesPrefixWithAttributes:(const char *)property_attributes{
    size_t len = strlen(property_attributes);
    char *prefix = malloc(len);
    memset(prefix, 0, len);
    memccpy(prefix, property_attributes, ',', len);

    return prefix;
}

+ (NSString *)getColumnTypeWithPropertyName:(NSString *)pName OwnClass:(Class )ownClass{
    
#if DEBUG
    if ([[NSString handleNetString:pName] isEqualToString:WGNull]) {
        WGLogError(@"pName不可为空");
    }
    if (ownClass==Nil) {
        WGLogError(@"ownClass不可为Nil");
    }
#endif
    
    const char *columnPropertyAttributes = property_getAttributes([self propertyInClass:ownClass WithName:pName]);
    
    //以 ','  号分割的第一个字符串
    char *column_pre = [self propertyAttributesPrefixWithAttributes:columnPropertyAttributes];
    
    u_int outCount;
    objc_property_t *properties  = class_copyPropertyList([WGSQLModelHelper class], &outCount);
    
    NSString *type = @"";
    
    for (u_int i = 0; i < outCount; i++) {
        const char *tmp = property_getAttributes(properties[i]);
        //以 ','  号分割的第一个字符串
        char *tmp_pre = [self propertyAttributesPrefixWithAttributes:tmp];
        
        if (strcmp(column_pre, tmp_pre)==0) {
            free(tmp_pre);
            type = [NSString stringWithUTF8String:property_getName(properties[i])];
            //如果type有 "_WG_**"后缀，需要去掉
            type = [type componentsSeparatedByString:@"$"].firstObject;
            
            break;
            
        }else{
            free(tmp_pre);
        }
    }
    
    if (type.length==0) {
        WGLogFormatError(@"WGSQLModelHelper中定义的基本类型不支持当前属性申明：class:%@,property_name:%@",NSStringFromClass(self),pName);
    }
    
    free(column_pre);
    free(properties);
    
    return type;
}
+ (NSString *)getEspecialColumnTypeWithPropertyName:(NSString *)pName OwnClass:(Class )ownClass{
#if DEBUG
    if ([[NSString handleNetString:pName] isEqualToString:WGNull]) {
        WGLogError(@"pName不可为空");
    }
    if (ownClass==Nil) {
        WGLogError(@"ownClass不可为Nil");
    }
#endif
    
    if ([ownClass conformsToProtocol:@protocol(WGEasyEspecialColumnTypeProtocol)] && [ownClass respondsToSelector:@selector(especialColumnType)]) {
        NSDictionary *especialColumnType = [ownClass especialColumnType];
        return [NSString handleNetString:especialColumnType[pName]];
    }else{
        return @"";
    }
    
}
@end

#pragma mark -
@implementation WGFMDBColumnModel
@synthesize
especialColumnType = _especialColumnType,
columnType = _columnType,
placeHolder = _placeHolder;

+ (instancetype)modelWithName:(NSString *)columnName OwnClass:(Class)class{
    return [[[self class]alloc]initWithName:columnName OwnClass:class];
}

- (id)initWithName:(NSString *)columnName OwnClass:(Class)class{
    if (self=[super init]) {
        _columnName = columnName;
        _ownClass = class;
    }
    return self;
}

#pragma mark - getter
- (NSString *)columnType{
    if (!_columnType) {
        if ([[NSString handleNetString:_columnName] isEqualToString:WGNull]) {
            WGLogError(@"WGFMDBColumnModel._columnName不可为空");
            return @"";
        }
        _columnType = [WGSQLModelHelper getColumnTypeWithPropertyName:_columnName OwnClass:_ownClass];
    }
    return _columnType;
}
- (NSString *)placeHolder{
    if (!_placeHolder) {
        _placeHolder = [NSString stringWithFormat:@":%@",_columnName];
    }
    return _placeHolder;
}
- (NSString *)especialColumnType{
    if (!_especialColumnType) {
        _especialColumnType = [WGSQLModelHelper getEspecialColumnTypeWithPropertyName:_columnName
                                                                             OwnClass:_ownClass];
    }
    return _especialColumnType;
}

#pragma mark -
+ (NSArray *)getColumnsWithClass:(Class)class Excepts:(NSArray *)excepts{
#if DEBUG
    if (class==Nil) {
        WGLogError(@"class不可为nil");
    }
#endif
    
    u_int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    NSMutableArray *propertyArray = @[].mutableCopy;
    //获取所有字段名
    for (u_int i = 0; i < outCount; i++) {
        const char *protocolName_CStr = property_getName(properties[i]);
        NSString *protocolName = [NSString stringWithUTF8String:protocolName_CStr];
        [propertyArray addObject:protocolName];
    }
    
    //过滤临时不需要存入数据库的字段
    if (excepts) {
        [propertyArray removeObjectsInArray:excepts];
    }

    //过滤全局不需要存入数据库的字段
    excepts = nil;
    if ([class conformsToProtocol:@protocol(WGEasyEspecialColumnTypeProtocol)]) {
        if ([class respondsToSelector:@selector(excepts)]) {
            excepts = [class excepts];
            [propertyArray removeObjectsInArray:excepts];
        }
    }
    
    //遍历，组成字符串
    NSMutableArray *models = @[].mutableCopy;
    for (NSString *name in propertyArray) {
        [models addObject:[WGFMDBColumnModel modelWithName:name OwnClass:class]];
    }
    
    return models;
}

@end
