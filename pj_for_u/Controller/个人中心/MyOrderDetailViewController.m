//
//  MyOrderDetailViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderDetailViewController.h"
#import "MyOrderTableViewCell.h"
#import "ShoppingCar.h"
#import "ConfirmOrderViewController.h"
#import "MyOrderEvaluationViewController.h"

#define kGetOrderDetailKey         @"GetOrderDetailKey"
#define kDeleteOrderKey             @"DeleteOrderKey"
#define kSetOrderInvalidKey         @"SetOrderInvalidKey"
#define kModifyOrderStatusKey       @"ModifyOrderStatusKey"

@interface MyOrderDetailViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSDictionary *bigOrder;
@property (strong, nonatomic) NSArray *smallOrders;
@property (strong, nonatomic) NSDictionary *receiver;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *totalPrice;
@property (strong, nonatomic) IBOutlet UILabel *togetherIdLabel;

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *phone;

@end

@implementation MyOrderDetailViewController

#pragma mark - Private Method
//改变cell按钮的类型
- (void)changeButtonTypeByStatus:(NSString *)status forTableViewCell:(MyOrderTableViewCell *)cell
{
    //通过status判断是什么状态，由此来确定每个按钮下应该显示的界面
    cell.rightButton.hidden = NO;
    cell.leftButton.hidden = NO;
    if ([status isEqualToString:@"1"]) {
        CALayer *layer = [cell.leftButton layer];
        layer.borderColor = [[UIColor redColor] CGColor];
        [cell.leftButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cell.leftButton setTitle:@"立即付款" forState:UIControlStateNormal];
        [cell.rightButton setTitle:@"取消订单" forState:UIControlStateNormal];
    }
    if ([status isEqualToString:@"2"]) {
        cell.leftButton.hidden = YES;
        [cell.rightButton setTitle:@"取消订单" forState:UIControlStateNormal];
    }
    if ([status isEqualToString:@"3"]) {
        cell.leftButton.hidden = YES;
        [cell.rightButton setTitle:@"确认收货" forState:UIControlStateNormal];;
    }
    if ([status isEqualToString:@"4"]) {
        CALayer *layer = [cell.leftButton layer];
        layer.borderColor = [[UIColor darkGrayColor] CGColor];
        [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [cell.leftButton setTitle:@"删除订单" forState:UIControlStateNormal];
        [cell.rightButton setTitle:@"评价订单" forState:UIControlStateNormal];;
    }
    if ([status isEqualToString:@"5"]) {
        cell.leftButton.hidden = YES;
        [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];;
    }

}

//请求修改订单状态
- (void)requsetForModifyOrderStatus:(NSString *)status togetherId:(NSString *)togetherId
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kModifyOrderStatusUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    if (status && togetherId) {
        [dict setObject:status forKey:@"status"];
        [dict setObject:togetherId forKey:@"togetherId"];
    }
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kModifyOrderStatusKey];
}

- (void)requestForDeleteOrder:(NSString *)togetherId
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kDeleteOrderUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:togetherId forKey:@"togetherId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kDeleteOrderKey];
}

- (void)requestForSetOrderInvalid:(NSString *)togetherId
{
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSetOrderInvalidUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:togetherId forKey:@"togetherId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kSetOrderInvalidKey];
}

- (void)requestForMyOrderDetailByTogetherId:(NSString *)togetherId
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kGetOrderDetailUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:self.togetherId forKey:@"togetherId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetOrderDetailKey];
}

- (void)loadOrderInfo
{
    int status = [[self.bigOrder objectForKey:@"status"] intValue];
    NSString *message;
    if (status == 1) {
        message = @"订单待付款";
    } else if (status == 2) {
        message = @"订单确认中";
    } else if (status == 3) {
        message = @"订单配送中";
    } else if (status == 4) {
        message = @"交易成功";
    } else if (status == 5) {
        message = @"交易完成";
    }
    
    self.status.text = message;
    self.togetherIdLabel.text = [self.bigOrder objectForKey:@"togetherId"];
    self.totalPrice.text = [NSString stringWithFormat:@"￥%.1lf", [[self.bigOrder objectForKey:@"totalPrice"] doubleValue]];
    self.name.text = [self.receiver objectForKey:@"name"];
    self.address.text = [self.receiver objectForKey:@"address"];
    self.phone.text = [self.receiver objectForKey:@"phone"];
}

//============点击左或者右两个按钮发生的事件，通过title来判断============
- (void)cilckOrderButtonNotification:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary *)notification.object;
    NSString *title = [dict objectForKey:@"title"];
    
    if ([title isEqualToString:@"评价订单"]) {
        NSMutableArray *realSmallOrders = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSDictionary *dict in self.smallOrders) {
            NSString *isRemarked = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isRemarked"]];
            if ([isRemarked isEqualToString:@"0"]) {
                [realSmallOrders addObject:dict];
            }
        }
        MyOrderEvaluationViewController *myOrderEvaluationViewController = [[MyOrderEvaluationViewController alloc] init];
        myOrderEvaluationViewController.smallOrders = realSmallOrders;
        
        [self.navigationController pushViewController:myOrderEvaluationViewController animated:YES];
        
    }
    
    else if ([title isEqualToString:@"删除订单"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除订单"
                                                                       message:@"是否删除订单？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self requestForDeleteOrder:self.togetherId];
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else if ([title isEqualToString:@"立即付款"]) {
        
        NSMutableArray *shoppingCar = [[NSMutableArray alloc] initWithCapacity:10];
        
        for (NSDictionary *dict in self.smallOrders) {
            ShoppingCar *car = [[ShoppingCar alloc] initWithDict:dict];
            [shoppingCar addObject:car];
        }
        
        ConfirmOrderViewController *coVC = [[ConfirmOrderViewController alloc] init];
        
        coVC.selectedArray = shoppingCar;
        
        [self.navigationController pushViewController:coVC animated:YES];
    }
    
    else if ([title isEqualToString:@"取消订单"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"取消订单"
                                                                       message:@"是否取消订单？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self requestForSetOrderInvalid:self.togetherId];
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    else if ([title isEqualToString:@"确认收货"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认收货"
                                                                       message:@"是否确认？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self requsetForModifyOrderStatus:@"4" togetherId:self.togetherId];
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderTableViewCell"
                                                                 forIndexPath:indexPath];
    
    if (self.smallOrders.count > 0)
    {
        cell.togetherDate.text = [self.bigOrder objectForKey:@"togetherDate"];
        cell.smallOrders = self.smallOrders;
        [cell.tableView reloadData];
        
        //后台不给。。。手动计算个数和总价
        int count = 0;
        double price = 0.0;
        NSString *realPriceType;
        for (NSDictionary *dict in self.smallOrders) {
            NSString *isDiscount = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isDiscount"]];
            if ([isDiscount isEqualToString:@"1"]) {
                realPriceType = @"discountPrice";
            } else {
                realPriceType = @"price";
            }
            int singleCount = [[dict objectForKey:@"orderCount"] intValue];
            double singlePrice = [[dict objectForKey:realPriceType] doubleValue];
            price += singleCount * singlePrice;
            count += singleCount;
        }
        cell.itsIndexPath = indexPath;
        cell.totalConut.text = [NSString stringWithFormat:@"共%d件商品", count];
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%.1lf", price];
        cell.canBeSelected = NO;
        
        NSString *status = [NSString stringWithFormat:@"%@", [self.bigOrder objectForKey:@"status"]];
        
        [self changeButtonTypeByStatus:status forTableViewCell:cell];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//因为只有一个cell，计算tableview和cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 108.f + self.smallOrders.count * 70.f;
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, 82 + 89 + 100 + height);
    CGRect frame = self.tableView.frame;
    frame.origin.y = 82 + 89;
    frame.size.height = height + 10;
    self.tableView.frame = frame;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}


#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}


#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"订单详情"];
    
    //register cell
    UINib *nib = [UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"MyOrderTableViewCell"];
    //=============

    [self requestForMyOrderDetailByTogetherId:self.togetherId];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cilckOrderButtonNotification:)
                                                 name:kCilckOrderButtonNotification object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];

    if ([downloader.purpose isEqualToString:kGetOrderDetailKey])
    {
        
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSDictionary *bigOrder = [dict objectForKey:@"BigOrder"];
            self.bigOrder = bigOrder;
            self.smallOrders = [bigOrder objectForKey:@"orders"];
            self.receiver = [bigOrder objectForKey:@"receiver"];
            [self loadOrderInfo];
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
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kDeleteOrderKey]) {
        NSString *message = [dict objectForKey:kMessageKey];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:message hideDelay:2.f];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"订单删除失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kSetOrderInvalidKey]) {
        NSString *message = [dict objectForKey:kMessageKey];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:message hideDelay:2.f];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"取消订单失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kModifyOrderStatusKey]) {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"确认成功" hideDelay:2.f];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *message = @"确认失败";
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
