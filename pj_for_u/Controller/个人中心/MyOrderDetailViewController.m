//
//  MyOrderDetailViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderDetailViewController.h"

@interface MyOrderDetailViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *name;

@end

@implementation MyOrderDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"订单详情"];
    
}


@end
