//
//  ImageContainView.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeSubView.h"

@interface ImageContainView : HomeSubView<YFCycleScrollViewDelegate>

@protocol ImagesContainViewDelegate;

@property (strong, nonatomic) IBOutlet YFCycleScrollView *cycleScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) id<ImagesContainViewDelegate> delegate;
@property (strong, nonatomic) NSArray *productAdArray;

- (void)reloadWithProductAds:(NSArray *)productAds;
@end

@protocol ImagesContainViewDelegate <NSObject>

- (void)didTappedWithProductAd:(AdModel *)productAd;
@end
