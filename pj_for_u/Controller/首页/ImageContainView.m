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

#pragma mark - Private methods
- (void)loadWithImages:(NSArray *)images
{
    self.pageControl.numberOfPages = images.count;
    self.pageControl.currentPage = 0;
    
    if (images.count <= 1) {
        self.scrollView.scrollEnabled = NO;
    }
    else {
        self.scrollView.scrollEnabled = YES;
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
    
    NSMutableArray *realImages = [[NSMutableArray alloc] initWithCapacity:10];
    [realImages addObject:[images lastObject]];
    [realImages addObjectsFromArray:images];
    [realImages addObject:[images firstObject]];
    
    for (int i = 0; i < realImages.count; i++) {
        YFAsynImageView *asynImgView = [[YFAsynImageView alloc] init];
        asynImgView.cacheDir = kImageCacheDir;
        [asynImgView aysnLoadImageWithUrl:realImages[i] placeHolder:@"home_image_default.png"];
        
        //设置frame
        CGRect rect = CGRectMake(i * ScreenWidth, 0, ScreenWidth, self.scrollView.frame.size.height);
        asynImgView.frame = rect;
        asynImgView.contentMode = UIViewContentModeScaleToFill;
        
        [self.scrollView addSubview:asynImgView];
    }
    
    [self.scrollView setContentSize:CGSizeMake(ScreenWidth * realImages.count, 0)];
    [self.scrollView setContentOffset:CGPointMake(ScreenWidth, 0) animated:NO];
}

- (void)onTimer
{
    NSInteger currentPage = self.pageControl.currentPage;
    CGPoint point = self.scrollView.contentOffset;
    
    if (currentPage == 0) {
        [self.scrollView setContentOffset:CGPointMake(ScreenWidth, point.y)];
        point = self.scrollView.contentOffset;
    }
    
    if (currentPage == self.pageControl.numberOfPages - 1) {
        self.pageControl.currentPage = 0;
        [self.scrollView setContentOffset:CGPointMake(point.x + ScreenWidth, point.y) animated:YES];
    } else {
        self.pageControl.currentPage++;
        [self.scrollView setContentOffset:CGPointMake(point.x + ScreenWidth, point.y) animated:YES];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    CGPoint point = self.scrollView.contentOffset;
    
    NSInteger page = ((NSInteger)(point.x / ScreenWidth) + 2) % self.imageUrlArray.count;
    
    self.pageControl.currentPage = page;
    
    if (page == self.imageUrlArray.count - 1) {
        [self.scrollView setContentOffset:CGPointMake(ScreenWidth * self.imageUrlArray.count, 0)];
    }
    if (point.x == ScreenWidth * self.imageUrlArray.count) {
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - UIView methods
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self requestForImages];
    self.scrollView.delegate = self;
}

#pragma mark - RYCycleScrollViewDelegate methods
- (void)didCycleScrollViewTappedWithIndex:(NSInteger)index
{
    //点击事件
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
            [self loadWithImages:self.imageUrlArray];
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
