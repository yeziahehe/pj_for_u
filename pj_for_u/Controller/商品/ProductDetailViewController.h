//
//  ProductDetailViewController.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"
#import "ProductionInfo.h"

@interface ProductDetailViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property(strong,nonatomic)NSString *foodId;
@property(strong,nonatomic)ProductionInfo *proInfo;
@end
