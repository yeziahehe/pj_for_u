//
//  MyOrderViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/31.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderTableViewCell.h"
#import "MyOrderDetailViewController.h"

#define kGetOrderInMineKey        @"GetOrderInMineKey"

@interface MyOrderViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *orderListArray;
@property (strong, nonatomic) NSMutableArray *eachCountOfSmallOrders;

@end

@implementation MyOrderViewController

- (void)pushToMyOrderDetailViewController:(NSNotification *)notification
{
    MyOrderDetailViewController *myOrderDetailViewController = [[MyOrderDetailViewController alloc] init];
    [self.navigationController pushViewController:myOrderDetailViewController animated:YES];

}

- (NSMutableArray *)eachCountOfSmallOrders
{
    if (!_eachCountOfSmallOrders) {
        _eachCountOfSmallOrders = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _eachCountOfSmallOrders;
}

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
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中..."];
    
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
    if (self.orderListArray) {
        NSDictionary *orderInfoDictionary = self.orderListArray[indexPath.section];
        NSArray *smallOrders = [orderInfoDictionary objectForKey:@"smallOrders"];
        cell.togetherDate.text = [orderInfoDictionary objectForKey:@"togetherDate"];
        cell.smallOrders = smallOrders;
        [cell.tableView reloadData];
        int count = 0;
        double price = 0.0;
        for (NSDictionary *dict in smallOrders) {
            int singleCount = [[dict objectForKey:@"orderCount"] intValue];
            double singlePrice = [[dict objectForKey:@"discountPrice"] doubleValue];
            price += singleCount * singlePrice;
            count += singleCount;
        }
        cell.itsIndexPath = indexPath;
        cell.totalConut.text = [NSString stringWithFormat:@"共%d件商品", count];
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%.1lf", price];
        
        NSString *status = [NSString stringWithFormat:@"%@", [orderInfoDictionary objectForKey:@"status"]];
        
        if ([status isEqualToString:@"1"]) {
            CALayer *layer = [cell.leftButton layer];
            layer.borderColor = [[UIColor redColor] CGColor];
            [cell.leftButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            cell.leftButton.titleLabel.text = @"删除订单";
            cell.rightButton.titleLabel.text = @"评价订单";
        }
        if ([status isEqualToString:@"2"]) {
            CALayer *layer = [cell.leftButton layer];
            layer.borderColor = [[UIColor darkGrayColor] CGColor];
            [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            
            cell.leftButton.titleLabel.text = @"删除订单";
            cell.rightButton.titleLabel.text = @"评价订单";
        }
        if ([status isEqualToString:@"3"]) {
            CALayer *layer = [cell.leftButton layer];
            layer.borderColor = [[UIColor darkGrayColor] CGColor];
            [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            
            cell.leftButton.titleLabel.text = @"删除订单";
            cell.rightButton.titleLabel.text = @"评价订单";
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyOrderDetailViewController *myOrderDetailViewController = [[MyOrderDetailViewController alloc] init];
    [self.navigationController pushViewController:myOrderDetailViewController animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.eachCountOfSmallOrders.count > indexPath.section) {
        return 108.f + [self.eachCountOfSmallOrders[indexPath.section] intValue] * 70.f;
    } else {
        return 178.f;
    }
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushToMyOrderDetailViewController:)
                                                 name:kPushToMyOrderDetailNotification object:nil];
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
            self.orderListArray = [dict objectForKey:@"orderList"];
            
            [self.eachCountOfSmallOrders removeAllObjects];
            for (NSDictionary *dict in self.orderListArray) {
                NSArray *smallOrders = [dict objectForKey:@"smallOrders"];
                NSNumber *smallOrderCount = [NSNumber numberWithInteger:smallOrders.count];
                [self.eachCountOfSmallOrders addObject:smallOrderCount];
            }
            
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
