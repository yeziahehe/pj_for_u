//
//  ProductionInfo.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/1.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 "foods": [
 {
 "foodId": 10505,
 "campusId": 1,
 "name": "明屋木瓜牛奶",
 "price": 10,
 "foodCount": 500,
 "discountPrice": 9,
 "imgUrl": "http://120.26.76.252:8080/MickeyImage/food/1430356924473-2020464999.jpg",
 "isDiscount": 1,
 "saleNumber": 7,
 "info": "http://img4.duitang.com/uploads/item/201208/11/20120811145508_JXksH.jpeg,http://www.pp3.cn/uploads/allimg/111111/092I4E50-6.jpg",
 "message": "所有食品都是绿色食品，不含防腐剂，您吃的放心是我们的荣幸",
 "grade": null
"commentCount": 1
 },
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
@property (nonatomic, copy) NSString *commentCount;

@end
