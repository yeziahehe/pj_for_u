//
//  NSString+YFMD5.m
//  pj_for_u
//
//  Created by 叶帆 on 15/9/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "NSString+YFMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (YFMD5)

- (NSString *)stringFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

@end
