//
//  ProImageView.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductSubView.h"
#import "ProductionInfo.h"

@interface ProImageView : ProductSubView

@property (strong,nonatomic)ProductionInfo *proInfo;
@property (strong,nonatomic)NSString *foodId;
@property(strong,nonatomic)NSString *imageUrl;

@end
