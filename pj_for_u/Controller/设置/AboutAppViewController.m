//
//  AboutAppViewController.m
//  pj_for_u
//
//  Created by 缪宇青 on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "AboutAppViewController.h"

@interface AboutAppViewController ()
@property (strong, nonatomic) IBOutlet UITextView *aboutTextView;

@end

@implementation AboutAppViewController

- (void)loadSubView
{
    [self setNaviTitle:@"关于我们"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.aboutTextView.text = [NSString stringWithFormat:@"%@",@" For优是由苏州英爵伟信息科技服务有限公司于2015年创建，致力于打造最优校园生活平台。紧跟潮流，运行互联网技术为大学生提供更优质便捷的生活，用户至上。\n  “为你 为更好的生活”，是我们始终奉行的服务理念"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
