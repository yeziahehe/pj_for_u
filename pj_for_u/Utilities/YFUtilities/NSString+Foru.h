//
//  NSString+Foru.h
//  pj_for_u
//
//  Created by 叶帆 on 15/9/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Foru)

/**
 *  通过字典顺序将参数键值对组合成字符串并进行MD5加密
 *
 *  @param dict 键值对NSDictionary
 *
 *  @return sign字符串
 */
+ (NSString *)signStringBySortFromParamDict:(NSMutableDictionary *)dict;

@end
