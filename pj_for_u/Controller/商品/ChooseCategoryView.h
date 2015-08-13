//
//  ShoppingDetailView.h
//  pj_for_u
//
//  Created by 牛严 on 15/8/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductionInfo.h"

@interface ChooseCategoryView : UIView
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet YFAsynImageView *productImage;
@property(strong,nonatomic)ProductionInfo *proInfo;
@property(strong,nonatomic)NSString *flag;
@end
