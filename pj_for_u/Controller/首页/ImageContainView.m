//
//  ImageContainView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ImageContainView.h"

#define kGetImagesDownloaderKey     @"GetImagesDownloaderKey"

@interface ImageContainView ()
@property (nonatomic, strong) NSMutableArray *imageUrlArray;
@property (nonatomic, strong) NSTimer *scrollTimer;
@end

@implementation ImageContainView
@synthesize cycleScrollView,pageControl;
@synthesize productAdArray;

#pragma mark - Private methods
- (void)reloadWithProductAds:(NSMutableArray *)productAds
{
    self.productAdArray = productAds;
    self.pageControl.numberOfPages = productAds.count;
    self.pageControl.currentPage = 0;
    
    NSMutableArray *images = [NSMutableArray array];
    for(NSString *productAd in productAds)
    {
        [images addObject:productAd];
    }
    
    [self.cycleScrollView reloadWithImages:images placeHolder:@"home_image_default.png" cacheDir:kImageCacheDir];
    
    if (self.pageControl.numberOfPages == 1) {
        self.cycleScrollView.scrollEnabled = NO;
    }
    else {
        self.cycleScrollView.scrollEnabled = YES;
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
}

- (void)onTimer
{
    //添加收尾各一张图实现循环滑动
    NSInteger papersCount = [self.productAdArray count]+2;
    //设置pagecontrol
    if (self.cycleScrollView.contentOffset.x/self.cycleScrollView.frame.size.width >= papersCount-2) {
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = self.cycleScrollView.contentOffset.x/self.cycleScrollView.frame.size.width;
    }
    //设置自动滑动
    if (self.cycleScrollView.contentOffset.x == 0)
    {
        [self.cycleScrollView scrollRectToVisible:CGRectMake(self.cycleScrollView.frame.size.width * papersCount ,0,self.cycleScrollView.frame.size.width, self.cycleScrollView.frame.size.height) animated:NO];
    }
    else if (self.cycleScrollView.contentOffset.x == (self.cycleScrollView.frame.size.width * (papersCount-1)))
    {
        [self.cycleScrollView scrollRectToVisible:CGRectMake(self.cycleScrollView.frame.size.width , 0, self.cycleScrollView.frame.size.width, self.cycleScrollView.frame.size.height) animated:NO];
    }
    else
    {
        [self.cycleScrollView setContentOffset:CGPointMake(self.cycleScrollView.contentOffset.x + self.cycleScrollView.frame.size.width, self.cycleScrollView.contentOffset.y) animated:YES];
    }
}

- (void)requestForImages
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetMainImageUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:kCampusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetImagesDownloaderKey];
}


#pragma mark - UIView methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self requestForImages];
    self.cycleScrollView.cycleDelegate = self;
    self.cycleScrollView.delegate = self.cycleScrollView.cycleDelegate;
}

#pragma mark - RYCycleScrollViewDelegate methods
- (void)didCycleScrollViewTappedWithIndex:(NSInteger)index
{
    //点击事件
}

- (void)scrollViewDidEndDecelerating:(YFCycleScrollView *)scrollView
{
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    if(page == 0)
    {
        [scrollView setContentOffset:CGPointMake((scrollView.cycleArray.count-2)*scrollView.frame.size.width, 0)];
        self.pageControl.currentPage = scrollView.cycleArray.count-3;
    }
    else if(page == scrollView.cycleArray.count-1)
    {
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0)];
        self.pageControl.currentPage = 0;
    }
    else
    {
        self.pageControl.currentPage = page-1;
    }
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetImagesDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
             self.imageUrlArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"newsList"];
            for (NSDictionary *valueDict in valueArray) {
                NSString *lm = [valueDict objectForKey:@"imgUrl"];
                [self.imageUrlArray addObject:lm];
            }
            [self reloadWithProductAds:self.imageUrlArray];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取图片失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
