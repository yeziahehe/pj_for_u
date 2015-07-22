//
//  LocationModel.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "LocationModel.h"
#import "CampusMoel.h"

@implementation LocationModel
@synthesize cityId,cityName,campuses;

- (id)initWithDict:(NSDictionary *)dict
{
    if(self = [super init])
    {
        for(NSString *key in [dict allKeys])
        {
            NSString *value = [dict objectForKey:key];
            if ([key isEqualToString:@"campuses"])
            {
                if (![value isKindOfClass:[NSNull class]])
                {
                    NSArray *valueArray = (NSArray *)value;
                    self.campuses = [NSMutableArray array];
                    for (NSDictionary *valueDict in valueArray)
                    {
                        CampusMoel *cm = [[CampusMoel alloc]initWithDict:valueDict];
                        [self.campuses addObject:cm];
                    }
                }
            }
            else
            {
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

@end
