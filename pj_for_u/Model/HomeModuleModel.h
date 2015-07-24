//
//  HomeModuleModel.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
 {
 "categoryId": 101,
 "serial": 1,
 "isOpen": 0
 }
 */
#import "BaseModel.h"

@interface HomeModuleModel : BaseModel
@property (nonatomic, copy) NSString *categoryId;//分类id
@property (nonatomic, copy) NSString *isOpen;//是否开通
@end
