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

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *subViewArray;
@end

@implementation HomeViewController

@synthesize contentScrollView,subViewArray;

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
            ImageContainView *icv = (ImageContainView *)homeSubView;
        }
        else if ([homeSubView isKindOfClass:[HomeContainView class]]) {
            HomeContainView *hcv = (HomeContainView *)homeSubView;
            rect.size.width = ScreenWidth;
            rect.size.height = ScreenWidth / 2.0;
        }
        homeSubView.frame = rect;
        [self.contentScrollView addSubview:homeSubView];
        originY = rect.origin.y + rect.size.height;
    }
    [self.contentScrollView setContentSize:CGSizeMake(ScreenWidth, originY)];
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
    [self setNaviTitle:@"未选择校区 > "];
    [self setLeftNaviItemWithTitle:nil imageName:@"btn_category.png"];
    [self setRightNaviItemWithTitle:nil imageName:@"btn_search.png"];
    [self loadSubViews];
}

@end
