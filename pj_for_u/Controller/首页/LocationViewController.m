//
//  LocationViewController.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "LocationViewController.h"
#import "CitySelectTableView.h"
#import "SchoolSelectTableView.h"
#import "LocationModel.h"
#import "CampusMoel.h"

#define kGetLocationDownloaderKey       @"GetLocationDownloaderKey"

@interface LocationViewController ()
@property (nonatomic, strong) NSMutableArray *cityArray;
@property (nonatomic, strong) NSMutableArray *schoolArray;
@property (nonatomic, assign) CGFloat originX;
@end

@implementation LocationViewController
@synthesize cityArray,schoolArray,originX;

#pragma mark - Private Methods
- (void)loadSubViews
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[LocationSubView class]]) {
            [subView removeFromSuperview];
        }
    }
    //加载CityUITableView
    CitySelectTableView *cstv = [[[NSBundle mainBundle] loadNibNamed:@"CitySelectTableView" owner:self options:nil] lastObject];
    CGRect rect = cstv.frame;
    rect.origin.y = 64.0f;
    rect.origin.x = 0.0f;
    rect.size.height = ScreenHeight;
    [cstv reloadWithLocationInfo:self.cityArray];
    cstv.frame = rect;
    self.originX = cstv.frame.size.width;
    [self.view addSubview:cstv];
    
    //加载SchoolUITableView
    LocationModel *lm = [self.cityArray objectAtIndex:0];
    self.schoolArray = [NSMutableArray arrayWithArray:lm.campuses];
    SchoolSelectTableView *sstv = [[[NSBundle mainBundle] loadNibNamed:@"SchoolSelectTableView" owner:self options:nil] lastObject];
    rect = sstv.frame;
    rect.origin.y = 64.f;
    rect.origin.x = self.originX;
    rect.size.height = ScreenHeight;
    rect.size.width = ScreenWidth - self.originX;
    [sstv reloadWithLocationInfo:self.schoolArray];
    sstv.frame = rect;
    [self.view addSubview:sstv];
}

- (void)requestForLocationInfo
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kLocationUrl];
    [[YFDownloaderManager sharedManager] requestDataByGetWithURLString:url
                                                              delegate:self
                                                               purpose:kGetLocationDownloaderKey];
}

#pragma mark - Notification Methods
- (void)citySelectNotification:(NSNotification *)notification
{
    NSNumber *number = [notification object];
    NSInteger index = [number integerValue];
    LocationModel *lm = [self.cityArray objectAtIndex:index];
    self.schoolArray = [NSMutableArray arrayWithArray:lm.campuses];
    // load campus view
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[SchoolSelectTableView class]]) {
            [subView removeFromSuperview];
        }
    }
    //加载SchoolUITableView
    SchoolSelectTableView *sstv = [[[NSBundle mainBundle] loadNibNamed:@"SchoolSelectTableView" owner:self options:nil] lastObject];
    CGRect rect = sstv.frame;
    rect.origin.y = 64.f;
    rect.origin.x = self.originX;
    rect.size.height = ScreenHeight;
    rect.size.width = ScreenWidth - self.originX;
    [sstv reloadWithLocationInfo:self.schoolArray];
    sstv.frame = rect;
    [self.view addSubview:sstv];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNaviTitle:@"选择学校"];
    //解决页面自动下降64px
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self requestForLocationInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citySelectNotification:) name:kCitySelectedNotificaition object:nil];
}

- (void)dealloc
{
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetLocationDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            self.cityArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"campus"];
            for (NSDictionary *valueDict in valueArray) {
                LocationModel *lm = [[LocationModel alloc]initWithDict:valueDict];
                [self.cityArray addObject:lm];
            }
            [self loadSubViews];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取校区信息失败";
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
