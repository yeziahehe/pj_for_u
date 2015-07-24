//
//  IndividualInfo.m
//  pj_for_u
//
//  Created by MiY on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "IndividualInfo.h"

@implementation IndividualInfo

- (instancetype)initWithimgUrl:(NSString *)imgUrl
                      nickname:(NSString *)nickname
                           sex:(NSInteger)sex
                       academy:(NSString *)academy
                            qq:(NSString *)qq
                        weixin:(NSString *)weixin
{
    self = [super init];

    if (self) {
        _imgUrl = imgUrl;
        _nickname = nickname;
        _sex = sex;
        _academy = academy;
        _qq = qq;
        _weixin = weixin;
    }
    return self;
}

@end
