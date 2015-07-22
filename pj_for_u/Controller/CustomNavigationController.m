//
//  CustomNavigationController.m
//  SJFood
//
//  Created by 叶帆 on 14/11/25.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "CustomNavigationController.h"
#import "HomeViewController.h"
#import "UserInfoViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

#pragma mark - Private Methods
- (void)navigationBarTappedWithGesture:(UITapGestureRecognizer *)tapGesture
{
    UIViewController *vc = self.visibleViewController;
    if([vc respondsToSelector:@selector(extraItemTapped)])
    {
        [vc performSelector:@selector(extraItemTapped)];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
    
    //加入头部点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTappedWithGesture:)];
    [self.navigationBar addGestureRecognizer:tapGesture];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[HomeViewController class]])
    {
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = nil;
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationBar.barTintColor = kMainProjColor;//导航条的颜色
        self.navigationBar.tintColor = [UIColor whiteColor];//左侧返回按钮，文字的颜色
        self.navigationBar.barStyle = UIStatusBarStyleLightContent;
    }
    
    else if([viewController isKindOfClass:[UserInfoViewController class]])
    {
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
    }
    else
    {
        [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = nil;
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: kMainBlackColor};
        self.navigationBar.barTintColor = [UIColor whiteColor];//导航条的颜色
        self.navigationBar.tintColor = kMainProjColor;//左侧返回按钮，文字的颜色
        self.navigationBar.barStyle = UIStatusBarStyleDefault;
    }
}

@end
