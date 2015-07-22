//
//  ImageContainView.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ImageContainView.h"

#define kGetImagesDownloaderKey  @"GetImagesDownloaderKey"
#define kImageCacheDir   @"ImageCacheDir"

@interface ImageContainView ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *imageUrlArray;

@end

@implementation ImageContainView
@synthesize cycleScrollView,pageControl;
@synthesize productAdArray;
@synthesize timer;

#pragma mark - Public methods
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
    
    [self.cycleScrollView reloadWithImages:images placeHolder:@"icon_house@2x.png" cacheDir:kImageCacheDir];
    
    if (self.pageControl.numberOfPages == 1) {
        self.cycleScrollView.scrollEnabled = NO;
    }
    else
        self.cycleScrollView.scrollEnabled = YES;
}

- (void)requestForImages
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kImageUrl];
    [[YFDownloaderManager sharedManager] requestDataByGetWithURLString:url
                                                              delegate:self
                                                               purpose:kGetImagesDownloaderKey];
}

- (void)didCycleScrollViewTappedWithIndex:(NSInteger)index
{

}
#pragma mark - UIView methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self requestForImages];
    self.cycleScrollView.cycleDelegate = self;
    self.cycleScrollView.delegate = self.cycleScrollView.cycleDelegate;
    CGFloat contentW = 2*self.cycleScrollView.frame.size.width;
    //不允许在垂直方向上进行滚动
    self.cycleScrollView.contentSize = CGSizeMake(contentW, 0);
    
    //3.设置分页
    self.cycleScrollView.pagingEnabled = YES;
    
    //4.监听scrollview的滚动
    self.cycleScrollView.delegate = self;
    [self addTimer];
    
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
- (void)nextImage
{
    int pagecount = (int)self.pageControl.currentPage;
    NSLog(@"%ld",(long)self.pageControl.currentPage);
    if (pagecount == 1) {
        //[self.cycleScrollView setContentOffset:CGPointMake((2)*self.cycleScrollView.frame.size.width, 0)];
        [self.cycleScrollView setContentOffset:CGPointMake(0, 0)];
        
    }
    else if (pageControl == 0){
        [self.cycleScrollView setContentOffset:CGPointMake(4*self.cycleScrollView.frame.size.width, 0)];
    }
    else
    {
        [self.cycleScrollView setContentOffset:CGPointMake(self.cycleScrollView.frame.size.width, 0)];
        
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    计算页码
    //    页码 = (contentoffset.x + scrollView一半宽度)/scrollView宽度
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    self.pageControl.currentPage = page;
}
// 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
    NSLog(@"移除定时器");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    开启定时器
    //[self addTimer];
    NSLog(@"开启定时器");
    
}

- (void)addTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer
{
    [self.timer invalidate];
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
