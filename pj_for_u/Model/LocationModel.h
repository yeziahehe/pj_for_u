//
//  LocationModel.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

/*
 {
    "cityId": 1,
    "cityName": "苏州",
    "campuses": [
        {
            "campusId": 1,
            "campusName": "苏州大学独墅湖校区",
            "cityId": null
        }
    ]
 },
 {
    "cityId": 2,
    "cityName": "南京",
    "campuses": [
        {
            "campusId": 2,
            "campusName": "南京大学雨花台校区",
            "cityId": null
        }
    ]
 }
 */

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface LocationModel : BaseModel

@property (nonatomic, copy) NSString *cityId;//城市id
@property (nonatomic, copy) NSString *cityName;//城市名称
@property (nonatomic, strong) NSMutableArray *campuses;//对应的学校id

- (id)initWithDict:(NSDictionary *)dict;

@end
