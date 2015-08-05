//
//  ProCommentDetail.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 "foodComments": [
 {
 "orderCount": 1,
 "foodId": 10101,
 "grade": 4,
 "nickName": "1",
 "isHidden": 1,
 "imgUrl": "http://120.26.76.252:8080/MickeyImage/users/-380161695731388361430296016122.jpg",
 "phone": "15295509505",
 "date": "2015-08-03",
 "campusId": 1,
 "comment": "22"
 }
 */

#import "BaseModel.h"

@interface ProCommentDetail : BaseModel
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *campusId;
@property (nonatomic, copy) NSString *grade;
@property (nonatomic, copy) NSString *orderCount;
@property (nonatomic, copy) NSString *foodId;
@property (nonatomic, copy) NSString *isHidden;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *imgUrl;

@end
