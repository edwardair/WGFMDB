//
//  NSObject+WGSQLModelHelper.h
//  Sqlit
//
//  Created by RayMi on 15/3/20.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"
#import <WGDefines.h>

/**
 *  间接获取Model的属性名字，通过Xcode的代码补全功能，对属性名称进行提示
 *
 *  @param sel 属性的get方法名
 *
 *  @return 方法名，也是属性名
 */
#define WGPNAME(sel) [NSObject getPropertyNameWitmMethod:@selector(sel)]

#ifndef WGOBJC//(value)
#define WGOBJC(value) _WGOBCJ(@encode(__typeof__((value))), (value))
static inline id _WGOBCJ(const char *type, ...) {
    va_list v;
    va_start(v, type);
    id obj = nil;
    
    if (strcmp(type, @encode(id)) == 0) {
        obj = va_arg(v, id);
    } else if (strcmp(type, @encode(CGPoint)) == 0) {
        CGPoint actual = (CGPoint)va_arg(v, CGPoint);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        CGSize actual = (CGSize)va_arg(v, CGSize);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(CGRect)) == 0) {
        CGRect actual = (CGRect)va_arg(v, CGRect);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets actual = (UIEdgeInsets)va_arg(v, UIEdgeInsets);
        obj = [NSValue value:&actual withObjCType:type];
    } else if (strcmp(type, @encode(double)) == 0) {
        double actual = (double)va_arg(v, double);
        obj = [NSNumber numberWithDouble:actual];
    } else if (strcmp(type, @encode(float)) == 0) {
        float actual = (float)va_arg(v, double);
        obj = [NSNumber numberWithFloat:actual];
    } else if (strcmp(type, @encode(int)) == 0) {
        int actual = (int)va_arg(v, int);
        obj = [NSNumber numberWithInt:actual];
    } else if (strcmp(type, @encode(long)) == 0) {
        long actual = (long)va_arg(v, long);
        obj = [NSNumber numberWithLong:actual];
    } else if (strcmp(type, @encode(long long)) == 0) {
        long long actual = (long long)va_arg(v, long long);
        obj = [NSNumber numberWithLongLong:actual];
    } else if (strcmp(type, @encode(short)) == 0) {
        short actual = (short)va_arg(v, int);
        obj = [NSNumber numberWithShort:actual];
    } else if (strcmp(type, @encode(char)) == 0) {
        char actual = (char)va_arg(v, int);
        obj = [NSNumber numberWithChar:actual];
    } else if (strcmp(type, @encode(bool)) == 0) {
        bool actual = (bool)va_arg(v, int);
        obj = [NSNumber numberWithBool:actual];
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char actual = (unsigned char)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedChar:actual];
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int actual = (unsigned int)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedInt:actual];
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long actual = (unsigned long)va_arg(v, unsigned long);
        obj = [NSNumber numberWithUnsignedLong:actual];
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long actual =
        (unsigned long long)va_arg(v, unsigned long long);
        obj = [NSNumber numberWithUnsignedLongLong:actual];
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short actual = (unsigned short)va_arg(v, unsigned int);
        obj = [NSNumber numberWithUnsignedShort:actual];
    }
    return obj;
}
#endif

/**
 *  通过model的属性名，获取model对应的属性值
 *
 *  @param model    任意model，或者对象
 *  @param selector model的成员方法名，可以通过get方式获取到返回值
 *
 *  @return 返回OC对像，如果model.selector返回的是C类型，则会转化为NSObject
 */
#define WGMODEL_VALUE(__model,__selector) \
({id __a;\
do {\
    _Pragma("clang diagnostic push")\
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
    __a =  WGOBJC([__model performSelector:NSSelectorFromString(__selector)]);\
    _Pragma("clang diagnostic pop")\
} while (0);\
__a;\
})

#pragma mark -
/**
 *  对于Model类型的对象，转化其属性名为NSString，数据库字段名
 */
@interface NSObject (WGSQLModelHelper)

+ (NSString *)getPropertyNameWitmMethod:(SEL )selector;

+ (instancetype)modelWithResultSet:(FMResultSet*)rs;

@end


#pragma mark - NSString category
@interface NSString (BigPrefix)
/**
 *  字符串第一个字母改为大写
 */
- (NSString *)uppercasePrefixString;
@end


