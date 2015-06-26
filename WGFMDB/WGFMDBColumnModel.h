//
//  WGFMDBColumnModel.h
//  Sqlit
//
//  Created by RayMi on 15/6/6.
//  Copyright (c) 2015年 RayMi. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  column相关的model
 */
@interface WGFMDBColumnModel : NSObject
+ (instancetype)modelWithName:(NSString *)columnName OwnClass:(Class )class;

- (id)initWithName:(NSString *)columnName OwnClass:(Class )class;

@property (nonatomic,copy) NSString *columnName;
@property (nonatomic,strong) Class ownClass;

/**
 *  column类型的特殊描述，默认为 @""空字符，
    在表创建时使用，可以指定column的主键、外键等特殊类型描述
 */
@property (nonatomic,copy,readonly) NSString *especialColumnType;
@property (nonatomic,copy,readonly) NSString *columnType;
@property (nonatomic,copy,readonly) NSString *placeHolder;


/**
 *  获取class中所有定义的属性数组，
 *
 *  @param class model.superclass
 *  @param excpets 如果存在，则忽略数组中的名字，
    注意：excepts是用户运行时额外定义的过滤，本身如果为nil的话，程序会忽略[class excpets]中标明的字段
 *
 *  @return @[WGFMDBColumnModel]
 */
+ (NSArray *)getColumnsWithClass:(Class)class Excepts:(NSArray *)excepts;
@end
