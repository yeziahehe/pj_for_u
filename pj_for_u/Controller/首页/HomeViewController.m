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
#import "GeneralProductViewController.h"
#import "CategoryInfo.h"
#import "ProductDetailViewController.h"

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
        if ([homeSubView isKindOfClass:[ImageContainView class]]) {

        }
        else if ([homeSubView isKindOfClass:[HomeContainView class]]) {
            //让HomeContainView width等于height的两倍，达到xib自动布局的效果
            rect.size.height = ScreenWidth / 2.0;
        }
        else if ([homeSubView isKindOfClass:[HomeActivityTableView class]]) {
            HomeActivityTableView *hat = (HomeActivityTableView *)homeSubView;
            if (self.imageUrlArray.count > 0) {
                [hat reloadWithActivityImages:self.imageUrlArray];
                hat.pushToProductDetail = ^(NSString *foodId) {
                    ProductDetailViewController *pdvc = [[ProductDetailViewController alloc] init];
                    pdvc.foodId = foodId;
                    [self.navigationController pushViewController:pdvc animated:YES];
                };
            }
            rect.size.height = hat.activityTableview.contentSize.height;
        }
        homeSubView.frame = rect;
        [self.contentScrollView addSubview:homeSubView];
        originY = rect.origin.y + rect.size.height;
    }
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth, originY)];
    [[MemberDataManager sharedManager] getPreferentialsInfo];

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
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshHomeNotification object:nil];
}

- (void)refreshHomeNotification:(NSNotification *)notification
{
    [self requestForImages];
}

- (void)homeButtonToProductWithNotification:(NSNotification *)notification
{
    GeneralProductViewController *gpv = [[GeneralProductViewController alloc]initWithNibName:@"GeneralProductViewController" bundle:nil];
    gpv.categoryInfo = notification.object;
    [self.navigationController pushViewController:gpv animated:YES];
}

- (void)searchButtonNotification:(NSNotification *)notification
{
    GeneralProductViewController *gpv = [[GeneralProductViewController alloc]initWithNibName:@"GeneralProductViewController" bundle:nil];
    gpv.foodTag = (NSString *)notification.object;
    [self.navigationController pushViewController:gpv animated:NO];
    
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
//    [self loadSubViews];
    [self requestForImages];
    [self.contentScrollView addHeaderWithTarget:self action:@selector(refreshHomeNotification:) dateKey:@"HomeViewController"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(campusNameNotification:) name:kCampusNameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeNotification:) name:kRefreshHomeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeButtonToProductWithNotification:) name:kButtonCategoryNotfication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchButtonNotification:) name:kSearchButtonNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.barTintColor = kMainProjColor;//导航条的颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//左侧返回按钮，文字的颜色
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
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
            self.imageUrlArray = [dict objectForKey:@"food"];

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
