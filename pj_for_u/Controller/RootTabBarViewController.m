//
//  RootTabBarViewController.m
//  SJFood
//
//  Created by 叶帆 on 14/11/25.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "UserInfoViewController.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController

@synthesize loginNavController;

#pragma mark - Properties Methods
- (CustomNavigationController *)loginNavController {
    if (nil == loginNavController) {
        LoginViewController *loginViewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        loginNavController = [[CustomNavigationController alloc]initWithRootViewController:loginViewController];
    } else {
        [loginNavController popToRootViewControllerAnimated:YES];
    }
    return loginNavController;
}

#pragma mark - Notification Methods
- (void)showLoginViewWithNotification:(NSNotification *)notification
{
    if(self.presentedViewController)
        [self dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:self.loginNavController animated:YES completion:nil];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tabBar.tintColor = kMainProjColor;
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginViewWithNotification:) name:kShowLoginViewNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - TabBarrController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *naviController = (UINavigationController *)viewController;
        id vc = [naviController topViewController];
        // to do
        if ([vc isKindOfClass:[HomeViewController class]])
        {
            
        }
        else if ([vc isKindOfClass:[UserInfoViewController class]]) {
            // to do
            if (vc != nil) {
                if ([[MemberDataManager sharedManager] isLogin]) {
                    [[MemberDataManager sharedManager] requestForIndividualInfoWithPhone:[MemberDataManager sharedManager].loginMember.phone];
                }
            }
        }
    }
    return YES;
}

@end
