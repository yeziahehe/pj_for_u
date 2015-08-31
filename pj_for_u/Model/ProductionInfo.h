//
//  ProductionInfo.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/1.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 "food": {
 "foodId": 10101,
 "name": "小当家干脆面",
 "price": 0.5,
 "discountPrice": 0.4,
 "grade": 4.6,
 "imgUrl": "http://120.26.76.252:8080/MickeyImage/food/1428302624611322199081.jpg",
 "info": "http://120.26.76.252:8080/ForyouImage/food/info/14386711936981107723134.jpg",
 "foodCount": 500,
 "modifyTime": 1432651904000,
 "status": 1,
 "foodFlag": "方便面，爆款",
 "tag": 1,
 "isDiscount": 0,
 "categoryId": 101,
 "primeCost": null,
 "saleNumber": 0,
 "commentNumber": 4,
 "campusId": 1
 }
 */

#import "BaseModel.h"

@interface ProductionInfo : BaseModel
@property (nonatomic, copy) NSString *foodId;
@property (nonatomic, copy) NSString *campusId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *foodCount;
@property (nonatomic, copy) NSString *discountPrice;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *isDiscount;
@property (nonatomic, copy) NSString *saleNumber;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *grade;
@property (nonatomic, copy) NSString *commentNumber;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *modifyTime;
@property (nonatomic, copy) NSString *foodFlag;
@property (nonatomic, copy) NSString *primeCost;
@property (nonatomic, copy) NSString *isFullDiscount;


@end
