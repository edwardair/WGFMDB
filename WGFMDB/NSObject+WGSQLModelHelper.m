//
//  NSObject+WGSQLModelHelper.m
//  Sqlit
//
//  Created by RayMi on 15/3/20.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import "NSObject+WGSQLModelHelper.h"
#import <objc/runtime.h>

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
    //MARK: argumentType暂时未用到，后期测试setValue是否可用再确定此参数是否使用
    [self setValue:[rs objectForColumnName:columnName] forKey:columnName];
}

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

