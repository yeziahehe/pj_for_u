//
//  RootTabBarViewController.h
//  SJFood
//
//  Created by 叶帆 on 14/11/25.
//  Copyright (c) 2014年 Ye Fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationController.h"

@interface RootTabBarViewController : UITabBarController<UITabBarControllerDelegate>

@property (nonatomic, strong)CustomNavigationController *loginNavController;

@end
