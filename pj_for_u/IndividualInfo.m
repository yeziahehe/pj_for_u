//
//  IndividualInfo.m
//  pj_for_u
//
//  Created by MiY on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualInfo.h"

@implementation IndividualInfo
@synthesize userInfo,waitDeliveryOrder,waitReceiveOrder,waitCommentOrder;

- (id)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        for (NSString *key in [dict allKeys]) {
            NSString *value = [dict objectForKey:key];
            if ([key isEqualToString:@"userInfo"]) {
                if(![value isKindOfClass:[NSNull class]])
                {
                    NSDictionary *valueDict = (NSDictionary *)value;
                    userInfo = [[UserInfo alloc] initWithDict:valueDict];
                }
            }
            else {
                if([value isKindOfClass:[NSNumber class]])
                    value = [NSString stringWithFormat:@"%@",value];
                else if([value isKindOfClass:[NSNull class]])
                    value = @"";
                @try {
                    [self setValue:value forKey:key];
                }
                @catch (NSException *exception) {
                    NSLog(@"试图添加不存在的key:%@到实例:%@中.",key,NSStringFromClass([self class]));
                }
            }
        }
    }
    return self;
}

+ (instancetype)mineInfoWithDict:(NSDictionary *)dict
{
    return [[IndividualInfo alloc] initWithDict:dict];
}

@end
