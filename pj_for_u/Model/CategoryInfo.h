//
//  ProductInfo.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 "foodCategory": [
 {
 "categoryId": 105,
 "campusId": 1,
 "category": "小优推荐",
 "imgUrl": null,
 "parentId": 0,
 "tag": 1,
 "serial": 5,
 "isOpen": 1,
 "child": null
 },
 */

#import <Foundation/Foundation.h>
#import "BaseModel.h"
@interface CategoryInfo : BaseModel
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *campusId;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *imgurl;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, copy) NSString *serial;
@property (nonatomic, copy) NSString *isopen;
@property (nonatomic, copy) NSString *child;



@end
