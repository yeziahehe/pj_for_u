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

#pragma mark - Private Methods

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


#pragma mark - Universal AND IBAciton
//==================随便逛逛================
- (IBAction)goAround
{
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:NO];
}

//==================将按钮边框和底下条纹设置成默认===========
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

//==============以下点击事件将待付款一栏和底下条纹颜色变为红色并调用网络请求================
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


#pragma mark - Initialize
//=========给待收货一栏按钮添加点击事件=========
- (void)addTargetToButton
{
    [self.waitForPayment addTarget:self action:@selector(waitForPaymentAction) forControlEvents:UIControlEventTouchUpInside];
    [self.waitForConfirm addTarget:self action:@selector(waitForConfirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.distributing addTarget:self action:@selector(distributingAction) forControlEvents:UIControlEventTouchUpInside];
    [self.waitForEvaluation addTarget:self action:@selector(waitForEvaluationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.alreadyFinished addTarget:self action:@selector(alreadyFinishedAction) forControlEvents:UIControlEventTouchUpInside];
}

- (NSMutableArray *)eachCountOfSmallOrders
{
    if (!_eachCountOfSmallOrders) {
        _eachCountOfSmallOrders = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _eachCountOfSmallOrders;
}


#pragma mark - Notification Methods
//=============订单详情===========
- (void)pushToMyOrderDetailViewController:(NSNotification *)notification
{
    NSIndexPath *indexPath = (NSIndexPath *)notification.object;
    
    NSDictionary *orderList = self.orderListArray[indexPath.section];
    
    NSString *togetherId = [orderList objectForKey:@"togetherId"];
    
    MyOrderDetailViewController *myOrderDetailViewController = [[MyOrderDetailViewController alloc] init];
    myOrderDetailViewController.togetherId = togetherId;
    
    [self.navigationController pushViewController:myOrderDetailViewController animated:YES];

}

//============点击左或者右两个按钮发生的事件，通过title来判断============
- (void)cilckOrderButtonNotification:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)notification.object;
    NSIndexPath *indexPath = [dict objectForKey:@"indexPath"];
    NSArray *smallOrders = [self.orderListArray[indexPath.section] objectForKey:@"smallOrders"];
    
    //评价订单，只显示未评价过得订单 if title = ...
    
    NSMutableArray *realSmallOrders = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary *dict in smallOrders) {
        NSString *isRemarked = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isRemarked"]];
        if ([isRemarked isEqualToString:@"0"]) {
            [realSmallOrders addObject:dict];
        }
    }
    MyOrderEvaluationViewController *myOrderEvaluationViewController = [[MyOrderEvaluationViewController alloc] init];
    myOrderEvaluationViewController.smallOrders = realSmallOrders;
    
    [self.navigationController pushViewController:myOrderEvaluationViewController animated:YES];
}


#pragma mark - UITableViewDataSource Methods
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
        
        //后台不给。。。手动计算个数和总价
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
        
        //通过status判断是什么状态，由此来确定每个按钮下应该显示的界面
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
            [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];
        }
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

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"我的订单"];
    
    //register cell
    UINib *nib = [UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderTableViewCell"];
    //=============
    
    [self addTargetToButton];
    
    //随便逛逛按钮增加圆角边框
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //每次进入页面刷新数据
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
            self.orderListArray = [dict objectForKey:@"orderList"];
            
            [self.eachCountOfSmallOrders removeAllObjects];
            for (NSDictionary *dict in self.orderListArray) {
                NSArray *smallOrders = [dict objectForKey:@"smallOrders"];
                NSNumber *smallOrderCount = [NSNumber numberWithInteger:smallOrders.count];
                [self.eachCountOfSmallOrders addObject:smallOrderCount];
            }
            
            //如果没数据就显示随便逛逛页面
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
                [self.noOrderView removeFromSuperview];
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
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}


@end
