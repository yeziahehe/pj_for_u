//
//  MyOrderViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderTableViewCell.h"

#define kGetOrderInMineKey        @"GetOrderInMineKey"

@interface MyOrderViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *orderInfoArray;

@end

@implementation MyOrderViewController

- (void)addTargetToButton
{
    [self.waitForPayment addTarget:self action:@selector(waitForPaymentAction) forControlEvents:UIControlEventTouchUpInside];
    [self.waitForConfirm addTarget:self action:@selector(waitForConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.distributing addTarget:self action:@selector(distributingAction) forControlEvents:UIControlEventTouchUpInside];
    [self.waitForEvaluation addTarget:self action:@selector(waitForEvaluationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.alreadyFinished addTarget:self action:@selector(alreadyFinishedAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)requestForMyOrderByStatus:(NSString *)status page:(NSString *)page limit:(NSString *)limit
{
//    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kGetOrderInMine];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:@"18896554880" forKey:@"phoneId"];
    if (status) {
        [dict setObject:status forKey:@"status"];
    }
    if (page && limit) {
        [dict setObject:page forKey:@"page"];
        [dict setObject:limit forKey:@"limit"];
    }
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetOrderInMineKey];
}
/*
waitForPaymentView;
waitForConfirmView;
distributingView;
waitForEvaluationView;
alreadyFinishedView;
 */

- (void)changeButtonToBlackColor
{
    self.waitForPayment.titleLabel.textColor = [UIColor darkGrayColor];
    self.waitForPaymentView.backgroundColor = [UIColor clearColor];
    self.waitForConfirm.titleLabel.textColor = [UIColor darkGrayColor];
    self.waitForConfirmView.backgroundColor = [UIColor clearColor];
    self.waitForEvaluation.titleLabel.textColor = [UIColor darkGrayColor];
    self.waitForEvaluationView.backgroundColor = [UIColor clearColor];
    self.distributing.titleLabel.textColor = [UIColor darkGrayColor];
    self.distributingView.backgroundColor = [UIColor clearColor];
    self.alreadyFinished.titleLabel.textColor = [UIColor darkGrayColor];
    self.alreadyFinishedView.backgroundColor = [UIColor clearColor];
}

- (void)waitForPaymentAction
{
    [self changeButtonToBlackColor];
    [self.waitForPayment setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.waitForPaymentView.backgroundColor = [UIColor redColor];
    
    [self requestForMyOrderByStatus:nil page:nil limit:nil];
}

- (void)waitForConfirmAction
{
    [self changeButtonToBlackColor];
    [self.waitForConfirm setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.waitForConfirmView.backgroundColor = [UIColor redColor];
    
    [self requestForMyOrderByStatus:@"1" page:nil limit:nil];
}

- (void)distributingAction
{
    [self changeButtonToBlackColor];
    
    [self.distributing setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.distributingView.backgroundColor = [UIColor redColor];
    
    [self requestForMyOrderByStatus:@"2" page:nil limit:nil];
}

- (void)waitForEvaluationAction
{
    [self changeButtonToBlackColor];
    [self.waitForEvaluation setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.waitForEvaluationView.backgroundColor = [UIColor redColor];
    
    [self requestForMyOrderByStatus:@"3" page:nil limit:nil];
}

- (void)alreadyFinishedAction
{
    [self changeButtonToBlackColor];
    [self.alreadyFinished setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.alreadyFinishedView.backgroundColor = [UIColor redColor];
    
    [self requestForMyOrderByStatus:nil page:nil limit:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderTableViewCell"
                                                                 forIndexPath:indexPath];
    if (self.orderInfoArray) {
        NSDictionary *orderInfoDictionary = self.orderInfoArray[indexPath.section];
        cell.togetherDate.text = [orderInfoDictionary objectForKey:@"togetherDate"];
        cell.nameLabel.text = [orderInfoDictionary objectForKey:@"name"];
        cell.price.text = [NSString stringWithFormat:@"%@", [orderInfoDictionary objectForKey:@"price"]];
        cell.image.cacheDir = kUserIconCacheDir;
        [cell.image aysnLoadImageWithUrl:[orderInfoDictionary objectForKey:@"imageUrl"] placeHolder:@"icon_user_default.png"];
        
//        UILabel *togetherDate;
//        UILabel *orderTypr;
//        UIImageView *image;
//        UILabel *nameLabel;
//        UILabel *price;
//        UILabel *orderConut;
//        UILabel *totalConut;
//        UILabel *totalPrice;

    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderInfoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 178.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"我的订单"];
    
    UINib *nib = [UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderTableViewCell"];
    
    [self addTargetToButton];
    [self waitForPaymentAction];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([downloader.purpose isEqualToString:kGetOrderInMineKey])
    {
        NSDictionary *dict = [str JSONValue];
        
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSArray *valueArray = [dict objectForKey:@"orderList"];
            self.orderInfoArray = [valueArray[0] objectForKey:@"smallOrders"];
            [self.tableView reloadData];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"信息获取失败";
        }
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
