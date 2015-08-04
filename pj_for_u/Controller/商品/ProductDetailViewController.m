//
//  ProductDetailViewController.m
//  pj_for_u
//
//  Created by 牛严 on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductSubView.h"
#import "ProImageView.h"
#import "ProInfoView.h"
#import "ProCommentView.h"


@interface ProductDetailViewController ()

@end

@implementation ProductDetailViewController

#pragma mark - Private Methods
-(void)loadSubViews{
    for (UIView *subView in self.contentScrollView.subviews)
    {
        if ([subView isKindOfClass:[ProductSubView class]]) {
            [subView removeFromSuperview];
        }
    }
    ProImageView *piv = [[[NSBundle mainBundle] loadNibNamed:@"ProImageView" owner:self options:nil]lastObject];
    CGRect rect = piv.frame;
    rect.origin.y = 64.f;
    piv.frame = rect;
    piv.imageUrl = self.proInfo.imgUrl;
    piv.proInfo = self.proInfo;
    [self.contentScrollView addSubview:piv];

    ProInfoView *pinv = [[[NSBundle mainBundle]loadNibNamed:@"ProInfoView" owner:self options:nil]lastObject];
    rect = pinv.frame;
    rect.origin.y = 64.f + piv.frame.size.height + 12.f;
    pinv.frame = rect;
    [self.contentScrollView addSubview:pinv];
}

#pragma mark - UIView Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNaviTitle:@"商品详情"];
    [self loadSubViews];
    NSLog(@"%@",self.proInfo.name);
    NSLog(@"%@",self.proInfo.price);
    NSLog(@"%@",self.foodId);
}

@end
