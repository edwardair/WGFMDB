//
//  NSObject+WGSQLModelHelper.m
//  Sqlit
//
//  Created by RayMi on 15/3/20.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "NSObject+WGSQLModelHelper.h"
#import <objc/runtime.h>
#import "WGDefines.h"

@implementation WGSQLModelHelper
@end

#pragma mark -
@implementation NSObject (WGSQLModelHelper)

+ (NSString *)getPropertyNameWitmMethod:(SEL )selector{
    NSString *name = [NSString stringWithFormat:@"%s",sel_getName(selector)];
    return name;
}

+ (instancetype)modelWithResultSet:(FMResultSet *)rs{
    id model = [[self alloc]init];
    
    //遍历 rs的所有 column
    for (int i = 0; i < rs.columnCount; i++) {
        NSString *columnName = [rs columnNameForIndex:i];
        
        /**
         *  检测 columnName是否为model的属性名，是的则赋值，否，继续循环
         *
         *  同时满足属性的set方法的，视为当前model的属性
         *  当model存在readonly等修饰的属性时，则不满足判断，无法赋值，
         *  但如果内部设置了set方法，也视为满足条件
         *
         *  @param columnName 数据库中的列名，等价于  model的属性名
         *
         *  @return YES：同时满足get、set方法，可赋值；NO：忽略
         */
        SEL selector = NSSelectorFromString(
                                            [NSString stringWithFormat:@"set%@:", [columnName uppercasePrefixString]]);
        if ([model respondsToSelector:selector]) {
            char argumentType[256];
            
            //前2个参数为每个方法的隐藏参数，故 index=2
            method_getArgumentType(class_getInstanceMethod(self, selector), 2, argumentType, 256);
            [model setValueWithResultSet:rs forColumnName:columnName WithArgType:argumentType];
        }else{
            continue;
        }
    }
    
    return model;
}

- (void)setValueWithResultSet:(FMResultSet *)rs forColumnName:(NSString *)columnName WithArgType:(char *)argumentType{
    //TODO: argumentType暂时未用到，后期测试setValue是否可用再确定此参数是否使用
    [self setValue:[rs objectForColumnName:columnName] forKey:columnName];
}


#pragma mark - 数据库column相关
+ (objc_property_t )propertyInProtocol:(Protocol *)protocol WithName:(NSString *)pName{
    u_int outCount;
    objc_property_t *properties  = protocol_copyPropertyList(protocol, &outCount);
    for (int i = 0; i < outCount; i++) {
        const char *tmp = property_getName(properties[i]);
        NSString *p_ = [NSString stringWithFormat:@"%s",tmp];
        
        if ([pName isEqualToString:p_]) {
            
            free(properties);
            return properties[i];
        }
    }
    
    free(properties);
    return NULL;
}


+ (NSString *)getColumnTypeWithPropertyName:(NSString *)pName BridgeProtocol:(Protocol *)protocol{

    const char *columnPropertyAttributes = property_getAttributes([self propertyInProtocol:protocol WithName:pName]);
   
    //以 ','  号分割的第一个字符串
    char *column_pre = malloc(strlen(columnPropertyAttributes));
    memset(column_pre, 0, strlen(columnPropertyAttributes));
    memccpy(column_pre, columnPropertyAttributes, ',', strlen(columnPropertyAttributes));
    
    u_int outCount;
    objc_property_t *properties  = class_copyPropertyList([WGSQLModelHelper class], &outCount);
    
    NSString *type = @"";
    
    for (int i = 0; i < outCount; i++) {
        const char *tmp = property_getAttributes(properties[i]);
        //以 ','  号分割的第一个字符串
        char *tmp_pre = malloc(strlen(tmp));
        memset(tmp_pre, 0, strlen(tmp));
        memccpy(tmp_pre, tmp, ',', strlen(tmp));

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
    
    free(column_pre);

    if (type.length==0) {
        WGLogFormatError(@"WGSQLModelHelper中定义的基本类型不支持当前属性申明：class:%@,property_name:%@",NSStringFromClass(self),pName);
    }
    
    free(properties);
    
    return type;
}

+ (NSString *)getColumnsWithBridgeProtocol:(Protocol *)bridgeProtocol
                                ModelClass:(Class )modelClass
                                    Except:(NSArray *)excpets
                            AppendWithType:(BOOL)hasColumnType{
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
    NSMutableString *sql = @"".mutableCopy;
    for (NSString *name in propertyArray) {
        if (hasColumnType) {
            [sql appendFormat:@"%@ %@,",name,[modelClass getColumnTypeWithPropertyName:name BridgeProtocol:bridgeProtocol]];
        }else{
            [sql appendFormat:@"%@,",name];
        }
    }
    
    if (sql.length) {
        [sql deleteCharactersInRange:NSMakeRange(sql.length-1,1)];
    }
    
    return sql;
    
}


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


@end




#pragma mark - NSString category
@implementation NSString(BigPrefix)
- (NSString *)uppercasePrefixString{
    if (self.length==0) {
        return self;
    }
    else{
        NSString *prefix = [self substringToIndex:1];
        
        NSString *remaining = [self substringFromIndex:1];
        
        return [NSString stringWithFormat:@"%@%@",[prefix uppercaseString],remaining];

    }
    
}
@end

