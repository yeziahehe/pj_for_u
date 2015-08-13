//
//  UserInfo.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 "phone": "18896554880",
 "password": null,
 "type": 2,
 "nickname": "12345",
 "imgUrl": "/foryou/Public/Uploads/2015-07-25/55b304908389a.jpg",
 "lastLoginDate": 1437926400000,
 "createTime": 1429027200000,
 "defaultAddress": null,
 "token": null,
 "sex": 1,
 "academy": "aq",
 "qq": 123232,
 "weiXin": "123456"
 */

#import "BaseModel.h"
#import <Foundation/Foundation.h>

typedef enum {
    kRoleAdmin = 0,
    kRoleCourier = 1,
    kRoleUser = 2
}RoleType;

@interface UserInfo : BaseModel

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *defaultAddress;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *academy;
@property (nonatomic, copy) NSString *weiXin;
@property (nonatomic, copy) NSString *qq;
@property (nonatomic, assign) RoleType roleType;

@end
