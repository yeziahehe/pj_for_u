//
//  NSString+YFMD5.h
//  pj_for_u
//
//  Created by 叶帆 on 15/9/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YFMD5)

/**
	字符串md5加密
	@returns 返回加密后的字符串
 */
- (NSString *)stringFromMD5;

@end
