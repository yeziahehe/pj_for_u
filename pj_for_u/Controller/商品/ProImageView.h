//
//  ProImageView.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductSubView.h"
#import "ProductionInfo.h"
#import "YFCycleScrollView.h"


@interface ProImageView : ProductSubView <UIScrollViewDelegate>

@property (strong, nonatomic) ProductionInfo *proInfo;
@property (strong, nonatomic) NSString *foodId;
@end
