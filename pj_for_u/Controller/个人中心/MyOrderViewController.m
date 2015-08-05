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
#import "MyOrderEvaluationViewController.h"

#define kGetOrderInMineKey        @"GetOrderInMineKey"

@interface MyOrderViewController ()

@property (strong, nonatomic) IBOutlet UIButton *waitForPayment;
@property (strong, nonatomic) IBOutlet UIButton *waitForConfirm;
@property (strong, nonatomic) IBOutlet UIButton *distributing;
@property (strong, nonatomic) IBOutlet UIButton *waitForEvaluation;
@property (strong, nonatomic) IBOutlet UIButton *alreadyFinished;

@property (strong, nonatomic) IBOutlet UIView *waitForPaymentView;
@property (strong, nonatomic) IBOutlet UIView *waitForConfirmView;
@property (strong, nonatomic) IBOutlet UIView *distributingView;
@property (strong, nonatomic) IBOutlet UIView *waitForEvaluationView;
@property (strong, nonatomic) IBOutlet UIView *alreadyFinishedView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *orderListArray;
@property (strong, nonatomic) NSMutableArray *eachCountOfSmallOrders;

@property (strong, nonatomic) IBOutlet UIView *noOrderView;
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;

@end

@implementation MyOrderViewController

- (IBAction)goAround
{
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)pushToMyOrderDetailViewController:(NSNotification *)notification
{
    MyOrderDetailViewController *myOrderDetailViewController = [[MyOrderDetailViewController alloc] init];
    
    
    
    [self.navigationController pushViewController:myOrderDetailViewController animated:YES];

}

- (void)cilckOrderButtonNotification:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)notification.object;
    NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
    
    NSArray *smallOrders = [self.orderListArray[indexPath.section] objectForKey:@"smallOrders"];
    
    
    MyOrderEvaluationViewController *myOrderEvaluationViewController = [[MyOrderEvaluationViewController alloc] init];
    
    myOrderEvaluationViewController.smallOrders = smallOrders;
    
    [self.navigationController pushViewController:myOrderEvaluationViewController animated:YES];
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

- (void)changeButtonToBlackColor
{
    [self.waitForPayment setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.waitForPaymentView.backgroundColor = [UIColor clearColor];
    
    [self.waitForConfirm setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.waitForConfirmView.backgroundColor = [UIColor clearColor];
    
    [self.waitForEvaluation setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.waitForEvaluationView.backgroundColor = [UIColor clearColor];
    
    [self.distributing setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.distributingView.backgroundColor = [UIColor clearColor];
    
    [self.alreadyFinished setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
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
            [cell.leftButton setTitle:@"删除订单" forState:UIControlStateNormal];
            [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];
        }
        if ([status isEqualToString:@"2"]) {
            CALayer *layer = [cell.leftButton layer];
            layer.borderColor = [[UIColor darkGrayColor] CGColor];
            [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            
            [cell.leftButton setTitle:@"删除订单" forState:UIControlStateNormal];
            [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];        }
        if ([status isEqualToString:@"3"]) {
            CALayer *layer = [cell.leftButton layer];
            layer.borderColor = [[UIColor darkGrayColor] CGColor];
            [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            
            [cell.leftButton setTitle:@"删除订单" forState:UIControlStateNormal];
            [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MyOrderDetailViewController *myOrderDetailViewController = [[MyOrderDetailViewController alloc] init];
//    [self.navigationController pushViewController:myOrderDetailViewController animated:YES];
    
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
    
    CALayer *layer = [self.goAroundButton layer];
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    layer.borderWidth = 1.f;
    self.goAroundButton.layer.masksToBounds = YES;
    self.goAroundButton.layer.cornerRadius = 2.5f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushToMyOrderDetailViewController:)
                                                 name:kPushToMyOrderDetailNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cilckOrderButtonNotification:)
                                                 name:kCilckOrderButtonNotification object:nil];
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
            
            if (self.orderListArray.count == 0) {
                self.tableView.hidden = YES;
                CGRect frame = self.noOrderView.frame;
                frame.origin.x = 0;
                frame.origin.y = 94;
                frame.size.width = ScreenWidth;
                frame.size.height = ScreenHeight - 94;
                self.noOrderView.frame = frame;
                [self.view addSubview:self.noOrderView];
            } else {
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
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
