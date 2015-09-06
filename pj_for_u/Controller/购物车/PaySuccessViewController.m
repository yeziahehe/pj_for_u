//
//  PaySuccessViewController.m
//  pj_for_u
//
//  Created by MiY on 15/9/5.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "PaySuccessViewController.h"
#import "MyOrderDetailViewController.h"
#import "ShoppingCarViewController.h"
#import "MyOrderViewController.h"
#import "ProductDetailViewController.h"
#import "ConfirmOrderViewController.h"

@interface PaySuccessViewController ()

@property (strong, nonatomic) IBOutlet UIButton *orderDetailButton;
@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *goodNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;

@property BOOL isJustReturn;
@end

@implementation PaySuccessViewController

- (void)loadInfo
{
    self.nameLabel.text = [self.order objectForKey:@"name"];
    self.addressLabel.text = [self.order objectForKey:@"address"];
    self.phoneLabel.text = [self.order objectForKey:@"phone"];
    NSString *price = [self.order objectForKey:@"price"];
    double realPrice = price.doubleValue;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%.1lf", realPrice];
    self.goodNumLabel.text = [NSString stringWithFormat:@"共%@件商品", [self.order objectForKey:@"count"]];
}

- (IBAction)qwer:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];

}

- (void)leftItemTapped
{
    self.isJustReturn = NO;
    for (BaseViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ShoppingCarViewController class]]
            || [vc isKindOfClass:[ProductDetailViewController class]]
            || [vc isKindOfClass:[MyOrderViewController class]])
        {
            [self.navigationController popToViewController:vc animated:NO];
        }
    }

}

- (void)orderDetailAction
{
    self.isJustReturn = NO;
    MyOrderDetailViewController *modvc = [[MyOrderDetailViewController alloc] init];
    modvc.togetherId = [self.order objectForKey:@"togetherId"];
    [self.navigationController pushViewController:modvc animated:YES];
}

- (void)returnAction
{
    self.isJustReturn = NO;
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initButton
{
    CALayer *layer = [self.orderDetailButton layer];
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 1.f;
    self.orderDetailButton.layer.masksToBounds = YES;
    self.orderDetailButton.layer.cornerRadius = 2.5f;
    
    layer = [self.returnButton layer];
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 1.f;
    self.returnButton.layer.masksToBounds = YES;
    self.returnButton.layer.cornerRadius = 2.5f;
    
    [self.orderDetailButton addTarget:self action:@selector(orderDetailAction) forControlEvents:UIControlEventTouchUpInside];
    [self.returnButton addTarget:self action:@selector(returnAction) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"支付成功"];
    
    [self initButton];
    [self loadInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isJustReturn = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isJustReturn) {
        for (BaseViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[ShoppingCarViewController class]]
                || [vc isKindOfClass:[ProductDetailViewController class]]
                || [vc isKindOfClass:[MyOrderViewController class]])
            {
                [self.navigationController popToViewController:vc animated:NO];
            }
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
