//
//  NSString+ParamString.m
//  BOEFace
//
//  Created by 叶帆 on 15/7/16.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import "NSString+ParamString.h"

@implementation NSString (ParamString)

+ (NSString *)paramSearchStringWithString:(NSString *)string
{
    NSString *param = [NSString stringWithFormat:@"%%25%@%%25",string];
    return param;
}

@end
