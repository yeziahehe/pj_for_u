//
//  AddressInfo.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/27.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

/*
 "receivers": [
              {
                  "rank": "1427300541891",
                  "phoneId": "18762885079",
                  "phone": "18762885079",
                  "name": "叶帆",
                  "address": "三江学院铁心桥主校区618",
                  "tag": 1
              },
 */

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface AddressInfo : BaseModel

@property (nonatomic, copy) NSString *rank;
@property (nonatomic, copy) NSString *phoneId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *tag;

@end
