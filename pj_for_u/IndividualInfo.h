//
//  IndividualInfo.h
//  pj_for_u
//
//  Created by MiY on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 {
 "message": "获取数据成功",
 "waitDeliveryOrder": null,
 "status": "success",
 "waitReceiveOrder": null,
 "userInfo": {
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
 },
 "waitCommentOrder": null
 }
 */
#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface  IndividualInfo: BaseModel

@property (nonatomic, copy) UserInfo *userInfo;

@property (nonatomic, copy) NSString *waitDeliveryOrder;
@property (nonatomic, copy) NSString *waitReceiveOrder;
@property (nonatomic, copy) NSString *waitCommentOrder;

- (id)initWithDict:(NSDictionary *)dict;
+ (instancetype)mineInfoWithDict:(NSDictionary *)dict;

@end