//
//  ProductDataManager.h
//  pj_for_u
//
//  Created by 牛严 on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDataManager : NSObject

+ (ProductDataManager *)sharedManager;

//请求分类信息
- (void)requestForAddressWithCampusId:(NSString *)campusId;
@end
