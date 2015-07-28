//
//  HomeViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/11/27.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "HomeViewController.h"
#import "LocationViewController.h"
#import "SearchHistoryViewController.h"
#import "ImageContainView.h"
#import "HomeContainView.h"
#import "HomeActivityTableView.h"
#import "ProductViewController.h"

#define kGetActivityImagesDownloaderKey  @"GetActivityImagesDownloaderKey"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *subViewArray;
@property (nonatomic, strong) NSMutableArray *imageUrlArray;

@end

@implementation HomeViewController

@synthesize contentScrollView,subViewArray,imageUrlArray;

#pragma mark - Private Methods
- (void)loadSubViews
{
    for (UIView *subView in self.contentScrollView.subviews)
    {
        if ([subView isKindOfClass:[HomeSubView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    self.subViewArray = [NSMutableArray arrayWithObjects:@"ImageContainView", @"HomeContainView", @"HomeActivityTableView",nil];
    
    //加载每个子模块
    CGFloat originY = 0.f;
    [self.contentScrollView layoutIfNeeded];
    for (NSString *classString in self.subViewArray) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:classString owner:self options:nil];
        HomeSubView *homeSubView = [nibs lastObject];
        CGRect rect = homeSubView.frame;
        rect.size.width = ScreenWidth;
        rect.origin.y = originY;
        rect.origin.x = 0.0f;
        if ([homeSubView isKindOfClass:[HomeContainView class]]) {
            //rect.size.height = ScreenWidth / 2.0;
        }
        else if ([homeSubView isKindOfClass:[HomeActivityTableView class]]) {
            HomeActivityTableView *hat = (HomeActivityTableView *)homeSubView;
            if (self.imageUrlArray.count > 0)
                [hat reloadWithActivityImages:self.imageUrlArray];
            rect.size.height = hat.activityTableview.contentSize.height;
        }
        homeSubView.frame = rect;
        [self.contentScrollView addSubview:homeSubView];
        originY = rect.origin.y + rect.size.height;
    }
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth, originY)];
}

- (void)requestForImages
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetActivityImageUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:kCampusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetActivityImagesDownloaderKey];
}

#pragma mark - NSNotification Methods
- (void)campusNameNotification:(NSNotification *)notification
{
    if (notification.object)
        [self setNaviTitle:[NSString stringWithFormat:@"%@ > ",notification.object]];
    [self loadSubViews];
}

- (void)refreshHomeNotification:(NSNotification *)notification
{
    [self loadSubViews];
    [self requestForImages];
}

#pragma mark - BaseViewController Methods
- (void)extraItemTapped
{
    //跳转到选择校区页面
    LocationViewController *locationViewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
    [self.navigationController pushViewController:locationViewController animated:YES];
}

- (void)leftItemTapped
{
    //跳转到商品分类页面
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    ProductViewController *productViewController = [[ProductViewController alloc]initWithNibName:@"ProductViewController" bundle:nil];
    [self.navigationController pushViewController:productViewController animated:YES];
}

- (void)rightItemTapped
{
    SearchHistoryViewController *searchHistoryViewController = [[SearchHistoryViewController alloc] initWithNibName:@"SearchHistoryViewController" bundle:nil];
    [self presentViewController:searchHistoryViewController animated:NO completion:^{
    }];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCampusNameKey]) {
        [self setNaviTitle:[NSString stringWithFormat:@"%@ > ",[[NSUserDefaults standardUserDefaults] objectForKey:kCampusNameKey]]];
    } else {
        [self setNaviTitle:@"未选择校区 > "];
    }
    [self setLeftNaviItemWithTitle:nil imageName:@"btn_category.png"];
    [self setRightNaviItemWithTitle:nil imageName:@"btn_search.png"];
    self.imageUrlArray = [NSMutableArray arrayWithCapacity:0];
    [self loadSubViews];
    [self requestForImages];
    [self.contentScrollView addHeaderWithTarget:self action:@selector(refreshHomeNotification:) dateKey:@"HomeViewController"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campusNameNotification:) name:kCampusNameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeNotification:) name:kRefreshHomeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetActivityImagesDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            self.imageUrlArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"food"];
            for (NSDictionary *valueDict in valueArray) {
                NSString *lm = [valueDict objectForKey:@"imgUrl"];
                [self.imageUrlArray addObject:lm];
            }
            [self.contentScrollView headerEndRefreshing];
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
                message = @"获取图片失败";
            [self.contentScrollView headerEndRefreshing];
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
