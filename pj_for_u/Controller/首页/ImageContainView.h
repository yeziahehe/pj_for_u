//
//  ImageContainView.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "HomeSubView.h"
#import "YFCycleScrollView.h"


@interface ImageContainView : HomeSubView<YFCycleScrollViewDelegate>
@property (strong, nonatomic) IBOutlet YFCycleScrollView *cycleScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *productAdArray;

- (void)reloadWithProductAds:(NSMutableArray *)productAds;

@end
