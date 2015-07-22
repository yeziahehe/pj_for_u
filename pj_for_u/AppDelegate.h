//
//  AppDelegate.h
//  pj_for_u
//
//  Created by 叶帆 on 15/7/21.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartViewController.h"
#import "RootTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) StartViewController *startViewController;
@property (strong, nonatomic) RootTabBarViewController *rootTabBarViewController;
@property (strong, nonatomic) Reachability *hostReachability;

@end

