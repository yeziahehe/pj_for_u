//
//  UserInfo.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize phone,nickname,imgUrl,roleType,type,academy,weiXin,sex,qq;

- (RoleType)roleType
{
    if ([self.type isEqualToString:@"0"])
        return kRoleAdmin;
    else if ([self.type isEqualToString:@"1"])
        return kRoleCourier;
    else
        return kRoleUser;
}

@end
