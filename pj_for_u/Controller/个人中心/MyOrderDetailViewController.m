//
//  MyOrderDetailViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/4.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "MyOrderDetailViewController.h"
#import "MyOrderTableViewCell.h"

#define kGetOrderDetailKey         @"GetOrderDetailKey"

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
        message = @"待付款";
    } else if (status == 2) {
        message = @"待确认";
    } else if (status == 3) {
        message = @"配送中";
    } else if (status == 4) {
        message = @"待评价";
    } else if (status == 5) {
        message = @"待确认";
    }
    
    self.status.text = message;
    self.togetherIdLabel.text = [self.bigOrder objectForKey:@"togetherId"];
    self.totalPrice.text = [NSString stringWithFormat:@"￥%.1lf", [[self.bigOrder objectForKey:@"totalPrice"] doubleValue]];
    self.name.text = [self.receiver objectForKey:@"name"];
    self.address.text = [self.receiver objectForKey:@"address"];
    self.phone.text = [self.receiver objectForKey:@"phone"];
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
        for (NSDictionary *dict in self.smallOrders) {
            int singleCount = [[dict objectForKey:@"orderCount"] intValue];
            double singlePrice = [[dict objectForKey:@"discountPrice"] doubleValue];
            price += singleCount * singlePrice;
            count += singleCount;
        }
        cell.itsIndexPath = indexPath;
        cell.totalConut.text = [NSString stringWithFormat:@"共%d件商品", count];
        cell.totalPrice.text = [NSString stringWithFormat:@"￥%.1lf", price];
        cell.canBeSelected = NO;
        
        NSString *status = [NSString stringWithFormat:@"%@", [self.bigOrder objectForKey:@"status"]];
        
        //通过status判断是什么状态，由此来确定每个按钮下应该显示的界面
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
            CALayer *layer = [cell.leftButton layer];
            layer.borderColor = [[UIColor darkGrayColor] CGColor];
            [cell.leftButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            
            [cell.leftButton setTitle:@"追加评论" forState:UIControlStateNormal];
            [cell.rightButton setTitle:@"删除订单" forState:UIControlStateNormal];;
        }
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 108.f + self.smallOrders.count * 70.f;
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, 82 + 89 + 30 + height);
    CGRect frame = self.tableView.frame;
    frame.origin.y = 82 + 89;
    frame.size.height = height + 8;
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
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([downloader.purpose isEqualToString:kGetOrderDetailKey])
    {
        NSDictionary *dict = [str JSONValue];
        
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
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
