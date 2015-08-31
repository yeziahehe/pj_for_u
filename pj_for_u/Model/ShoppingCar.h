//
//  ShoppingCar.h
//  pj_for_u
//
//  Created by 缪宇青 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/**
 {
 "message": "获取购物车订单成功",
 "status": "success",
 "orderList": [
 {
 "orderId": 1438663229,
 "name": "格力高 百奇牛奶草莓味45g",
 "phone": null,
 "status": 1,
 "price": 6,
 "discountPrice": 5.5,
 "isDiscount": 1,
 "orderCount": 2,
 "tag": 1,
 "foodId": 10703,
 "imageUrl": "http://120.26.76.252:8080/MickeyImage/food/1430900736071762270326.jpg",
 "foodCount": null
 }
 ]
 }
 */
#import <Foundation/Foundation.h>

@interface ShoppingCar : NSObject

@property (nonatomic, copy) NSString *orderId;//购物车每条记录的id
@property (nonatomic, copy) NSString *name;//商品名称
@property (nonatomic, copy) NSString *price;//商品价格
@property (nonatomic, copy) NSString *discountPrice;//折扣价格
@property (nonatomic, copy) NSString *isDiscount;//是否打折
@property (nonatomic, strong) NSString *orderCount;//商品数量(允许修改)
@property (nonatomic, copy) NSString *imageUrl;//商品照片
@property (nonatomic, copy) NSString *foodCount;//商品余量
@property (nonatomic, copy) NSString *foodId;//商品id
@property (nonatomic, copy) NSString *isFullDiscount;//是否满减优惠


- (id)initWithDict:(NSDictionary *)dict;
+ (instancetype)shoppingCarWithDict:(NSDictionary *)dict;
@end
