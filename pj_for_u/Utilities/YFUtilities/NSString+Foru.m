//
//  NSString+Foru.m
//  pj_for_u
//
//  Created by 叶帆 on 15/9/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "NSString+Foru.h"

@implementation NSString (Foru)

+ (NSString *)signStringBySortFromParamDict:(NSMutableDictionary *)dict {
    NSMutableDictionary *sortDict = [dict mutableCopy];
    [sortDict removeObjectsForKeys:[NSArray arrayWithObjects:@"timestamp", @"secret", nil]];
    NSArray *sortedKeys = [[sortDict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];

    NSMutableString *result = [NSMutableString string];
    
    if (sortedKeys.count != 0) {
        for(NSString *sortKey in sortedKeys){
            for(NSString *key in [sortDict allKeys]){
                if ([key isEqualToString:sortKey]) {
                    NSString *value = [NSString stringWithFormat:@"%@",[sortDict objectForKey:key]];
                    [result appendFormat:@"%@=%@", key, value];
                }
            }
        }
    }
    
    [result appendFormat:kSecret];
    result = [result stringFromMD5];
    
    return result;
}

@end
