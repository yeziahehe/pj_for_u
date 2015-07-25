//
//  FirstClassModel.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 {
 "categoryId": 105,
 "campusId": 1,
 "category": "进口零食",
 "imgUrl": null,
 "parentId": 0,
 "tag": 1,
 "child": null
 }
 */

#import "BaseModel.h"

@interface FirstClassModel : BaseModel
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *category;
@end