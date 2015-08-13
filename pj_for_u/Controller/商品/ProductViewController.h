//
//  ProductViewController.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BaseViewController.h"

@interface ProductViewController : BaseViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *smallScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *bigScrollView;

@end
