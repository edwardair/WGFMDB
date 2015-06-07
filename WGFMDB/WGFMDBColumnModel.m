//
//  WGFMDBColumnModel.m
//  Sqlit
//
//  Created by RayMi on 15/6/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "WGFMDBColumnModel.h"
#import <objc/runtime.h>
#import <WGCategory/WGDefines.h>
#import "NSObject+WGSQLModelHelper.h"

#pragma mark - WGSQL支持的属性转column类型定义
@interface WGSQLModelHelper : NSObject
//TODO: 后期扩展支持字段...
/**
 *  如果属性名以  "_WG_**"结尾，在转化column类型时需要去掉
 */
@property NSString *TEXT_WG_String;
@property NSNumber *TEXT_WG_Number;

@property int INT;
@property NSInteger INT_WG_Integer;

@property float FLOAT;
@property NSTimeInterval FLOAT_WG_TimeInterval;

@property double DOUBLE;

@property BOOL BIT;

/**
 *  获取protocol的属性名对应的数据库类型名
 *
 *  @param pName    protocol中定义的get方法、或者属性名
 *  @param protocol model存入数据库的桥接协议
 *
 *  @return 存数据库中的数据库cloumn基本类型
 */
+ (NSString *)getColumnTypeWithPropertyName:(NSString *)pName BridgeProtocol:(Protocol *)protocol;

/**
 *  获取所有column字段名
 *
 *  @param bridgeProtocol model存入数据库的桥接协议
 *  @param excpets        数组中的除外，用于update、insert时
 *  @param hasColumnType  建表时需要，附带column的类型，如  TEXT、BIT等数据库类型
 *
 */
+ (NSString *)getColumnsWithBridgeProtocol:(Protocol *)bridgeProtocol
                                    Except:(NSArray *)excpets
                            AppendWithType:(BOOL)hasColumnType;

@end

@implementation WGSQLModelHelper
#if DEBUG
+ (void)DEBUG_ShowAllColumnTypesInWGSQLModelHelper{
    u_int outCount;
    objc_property_t *properties  = class_copyPropertyList([WGSQLModelHelper class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        const char *attributes_name = property_getAttributes(properties[i]);
        const char *property_name = property_getName(properties[i]);
        
        WGLogFormatValue(@"\n属性名：%s\nAttributes:%s",property_name,attributes_name);
    }
    
    free(properties);
}

+ (void)load{
    [self DEBUG_ShowAllColumnTypesInWGSQLModelHelper];
}
#endif

#pragma mark - 数据库column相关
+ (objc_property_t )propertyInProtocol:(Protocol *)protocol WithName:(NSString *)pName{
    u_int outCount;
    objc_property_t *properties  = protocol_copyPropertyList(protocol, &outCount);
    objc_property_t p;
    for (int i = 0; i < outCount; i++) {
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
 *  @param property_attributes <#property_attributes description#>
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

+ (NSString *)getColumnTypeWithPropertyName:(NSString *)pName BridgeProtocol:(Protocol *)protocol{
    
#if DEBUG
    if ([[NSString handleNetString:pName] isEqualToString:WGNull]) {
        WGLogError(@"pName不可为空");
    }
    if (!protocol) {
        WGLogError(@"bridge protocol不可为nil");
    }
#endif
    
    const char *columnPropertyAttributes = property_getAttributes([self propertyInProtocol:protocol WithName:pName]);
    
    //以 ','  号分割的第一个字符串
    char *column_pre = [self propertyAttributesPrefixWithAttributes:columnPropertyAttributes];
    
    u_int outCount;
    objc_property_t *properties  = class_copyPropertyList([WGSQLModelHelper class], &outCount);
    
    NSString *type = @"";
    
    for (int i = 0; i < outCount; i++) {
        const char *tmp = property_getAttributes(properties[i]);
        //以 ','  号分割的第一个字符串
        char *tmp_pre = [self propertyAttributesPrefixWithAttributes:tmp];
        
        if (strcmp(column_pre, tmp_pre)==0) {
            free(tmp_pre);
            type = [NSString stringWithUTF8String:property_getName(properties[i])];
            //如果type有 "_WG_**"后缀，需要去掉
            type = [type componentsSeparatedByString:@"_WG_"].firstObject;
            
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

@end

#pragma mark -
@implementation WGFMDBColumnModel
@synthesize
columnType = _columnType,
bridgeProtocol = _bridgeProtocol,
placeHolder = _placeHolder;

+ (instancetype)modelWithName:(NSString *)columnName BridgeProtocol:(Protocol *)bridgeProtocol{
    return [[[self class]alloc]initWithName:columnName
                             BridgeProtocol:bridgeProtocol];
}

- (id)initWithName:(NSString *)columnName BridgeProtocol:(Protocol *)bridgeProtocol{
    if (self=[super init]) {
        _columnName = columnName;
        _bridgeProtocol = bridgeProtocol;
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
        _columnType = [WGSQLModelHelper getColumnTypeWithPropertyName:_columnName BridgeProtocol:_bridgeProtocol];
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
        _especialColumnType = @"";
    }
    return _especialColumnType;
}

#pragma mark -
+ (NSArray *)getColumnsWithBridgeProtocol:(Protocol *)bridgeProtocol
                                    Except:(NSArray *)excpets{
#if DEBUG
    if (!bridgeProtocol) {
        WGLogError(@"bridge protocol不可为nil");
    }
#endif
    
    u_int outCount;
    objc_property_t *properties = protocol_copyPropertyList(bridgeProtocol, &outCount);
    NSMutableArray *propertyArray = @[].mutableCopy;
    //获取所有字段名
    for (int i = 0; i < outCount; i++) {
        const char *protocolName_CStr = property_getName(properties[i]);
        NSString *protocolName = [NSString stringWithUTF8String:protocolName_CStr];
        [propertyArray addObject:protocolName];
    }
    //过滤
    if (excpets.count) {
        [propertyArray removeObjectsInArray:excpets];
    }
    
    //遍历，组成字符串
    NSMutableArray *models = @[].mutableCopy;
    for (NSString *name in propertyArray) {
        [models addObject:[WGFMDBColumnModel modelWithName:name BridgeProtocol:bridgeProtocol]];
    }
    
    return models;
}

@end
