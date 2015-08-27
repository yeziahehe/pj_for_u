//
//  CourierViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/25.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "CourierViewController.h"
#import "CourierTableViewCell.h"

#define kDeliverAdminGetOrderKey            @"DeliverAdminGetOrderKey"
#define kModifyOrderStatusKey               @"ModifyOrderStatusKey"

@interface CourierViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cellArray;
@property (strong, nonatomic) NSMutableArray *eachCountOfOrderList;       //保存每个大订单中小订单的个数

@property NSInteger deleteIndex;
@end

@implementation CourierViewController

- (void)refreshHeader
{
    [self requestForCourier];
}

- (NSMutableArray *)eachCountOfOrderList
{
    if (!_eachCountOfOrderList) {
        _eachCountOfOrderList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _eachCountOfOrderList;
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


- (void)requestForCourier
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kDeliverAdminGetOrderUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:[MemberDataManager sharedManager].loginMember.phone forKey:@"phoneId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kDeliverAdminGetOrderKey];
}

- (void)adminChangeOrderStatus:(NSNotification *)notification
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"派送完成"
                                                                   message:@"是否确定派送完成？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                NSDictionary *dict = (NSDictionary *)notification.object;
                                                NSString *togetherId = [dict objectForKey:@"togetherId"];
                                                NSIndexPath *indexPath = (NSIndexPath *)[dict objectForKey:@"indexPath"];
                                                self.deleteIndex = indexPath.section;

                                                [self requsetForModifyOrderStatus:@"4" togetherId:togetherId];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CourierTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourierTableViewCell"
                                                                    forIndexPath:indexPath];
    
    NSDictionary *dict = self.cellArray[indexPath.section];
    
    cell.togetherDate.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"togetherDate"]];
    cell.address.text = [NSString stringWithFormat:@"地址:%@", [dict objectForKey:@"address"]];
    
    int type = [NSString stringWithFormat:@"%@", [dict objectForKey:@"status"]].intValue;
    switch (type) {
        case 1:
            cell.status.text = @"订单待付款";
            break;
        case 2:
            cell.status.text = @"订单待确认";
            break;
        case 3:
            cell.status.text = @"订单配送中";
            break;
        case 4:
            cell.status.text = @"订单待评价";
            break;
        case 5:
            cell.status.text = @"订单已完成";
            break;
        default:
            break;
    }
    
    cell.customePhone.text = [NSString stringWithFormat:@"手机:%@", [dict objectForKey:@"customePhone"]];
    cell.togetherId.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"togetherId"]];
    cell.nickName.text = [NSString stringWithFormat:@"昵称:%@", [dict objectForKey:@"nickName"]];
    cell.totalPrice.text = [NSString stringWithFormat:@"总价:%@", [dict objectForKey:@"totalPrice"]];
    cell.reserveTime.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"reserveTime"]];
    cell.message.text = [NSString stringWithFormat:@"备注:%@", [dict objectForKey:@"message"]];
    
    cell.orderList = [dict objectForKey:@"orderList"];
    cell.itsIndexPath = indexPath;
    
    [cell.tableView reloadData];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cellArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.eachCountOfOrderList.count > indexPath.section) {
        return 209.0 + [self.eachCountOfOrderList[indexPath.section] intValue] * 55.0;
    } else {
        return 264.0;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviTitle:@"待配送订单"];
    
    UINib *nib = [UINib nibWithNibName:@"CourierTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"CourierTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adminChangeOrderStatus:) name:kAdminChangeOrderStatusNotification object:nil];
    
    [self requestForCourier];

    [self.tableView addHeaderWithTarget:self action:@selector(refreshHeader)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    
    if ([downloader.purpose isEqualToString:kDeliverAdminGetOrderKey])
    {
        [self.tableView headerEndRefreshing];

        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            
            self.cellArray = [dict objectForKey:@"orderList"];
            
            for (NSDictionary *dict in self.cellArray) {
                NSArray *orderList = [dict objectForKey:@"orderList"];
                NSNumber *orderListCount = [NSNumber numberWithInteger:orderList.count];
                [self.eachCountOfOrderList addObject:orderListCount];
            }
            
            [self.tableView reloadData];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
            if(message.length == 0)
                message = @"信息获取失败";
            
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kModifyOrderStatusKey])
    {
        NSString *message = [dict objectForKey:kMessageKey];
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] showSuccessViewWithMessage:@"派送成功" hideDelay:2.f];

            [self.cellArray removeObjectAtIndex:self.deleteIndex];
            [self.eachCountOfOrderList removeObjectAtIndex:self.deleteIndex];
            
            [self.tableView reloadData];
        }
        else
        {
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
            if(message.length == 0)
                message = @"确认失败";
            
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
