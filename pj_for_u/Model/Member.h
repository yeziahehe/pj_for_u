//
//  Member.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//
/*
{
    "message": "登陆成功",
    "status": "success",
    "type": 0
}
 */

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Member : BaseModel
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *type;//0 1 2 代表``` 

+ (instancetype)memberWithDict:(NSDictionary *)dict;
@end
