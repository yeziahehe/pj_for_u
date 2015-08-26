//
//  BigManageViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/24.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "BigManageViewController.h"
#import "BigManageTableViewCell.h"
#import "BigManageSubViewController.h"

#define kSuperAdminGetOrderKey              @"SuperAdminGetOrderKey"

@interface BigManageViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *orderList;
@property (strong, nonatomic) IBOutlet UIButton *isNotSelectedButton;
@property (strong, nonatomic) IBOutlet UIButton *isSelectedButton;

@property int recordStatus;

@end

@implementation BigManageViewController

- (void)refreshHeader
{
    NSString *status = [NSString stringWithFormat:@"%d", self.recordStatus];
    [self requestForBigManagesOrder:status];
}


- (void)requestForBigManagesOrder:(NSString *)isSelected
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中..."];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kServerAddress, kSuperAdminGetOrderUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    
    [dict setObject:isSelected forKey:@"isSelected"];
    [dict setObject:kCampusId forKey:@"campusId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kSuperAdminGetOrderKey];
}

- (void)isSelectedAction
{
    self.isSelectedButton.backgroundColor = [UIColor orangeColor];
    
    self.isNotSelectedButton.backgroundColor = [UIColor whiteColor];
    
    self.recordStatus = 1;
    
    [self requestSelectedAction];
}

- (void)isNotSelectedAction
{
    self.isNotSelectedButton.backgroundColor = [UIColor orangeColor];
    
    self.isSelectedButton.backgroundColor = [UIColor whiteColor];
    
    self.recordStatus = 0;
    
    [self requestSelectedAction];
}

- (void)requestSelectedAction
{
    [self requestForBigManagesOrder:[NSString stringWithFormat:@"%d", self.recordStatus]];
}

- (void)addTargetToButton
{
    
    [self.isSelectedButton addTarget:self action:@selector(isSelectedAction) forControlEvents:UIControlEventTouchUpInside];
    [self.isNotSelectedButton addTarget:self action:@selector(isNotSelectedAction) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BigManageTableViewCell"
                                                                 forIndexPath:indexPath];
    if (self.orderList) {
        NSDictionary *dict = self.orderList[indexPath.row];
        cell.togetherDate.text = [NSString stringWithFormat:@"日期:%@", [dict objectForKey:@"togetherDate"]];
        cell.togetherId.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"togetherId"]];
        cell.address.text = [NSString stringWithFormat:@"地址:%@", [dict objectForKey:@"address"]];
        cell.price.text = [NSString stringWithFormat:@"价格:%@", [dict objectForKey:@"price"]];
        cell.reserveTime.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"reserveTime"]];
        cell.adminName.text = [NSString stringWithFormat:@"配送员:%@", [dict objectForKey:@"adminName"]];

    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 118.0;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BigManageTableViewCell *cell = (BigManageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    BigManageSubViewController *bmsvc = [[BigManageSubViewController alloc] init];
    
    bmsvc.togetherId = cell.togetherId.text;
    
    [self.navigationController pushViewController:bmsvc animated:YES];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNaviTitle:@"所有订单"];
    
    //register cell
    UINib *nib = [UINib nibWithNibName:@"BigManageTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:@"BigManageTableViewCell"];
    //=============

    [self addTargetToButton];
    
    self.recordStatus = 0;
    self.isNotSelectedButton.backgroundColor = [UIColor orangeColor];
    self.isSelectedButton.backgroundColor = [UIColor whiteColor];
    
    [self.tableView addHeaderWithTarget:self action:@selector(refreshHeader)];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestSelectedAction];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    
    if ([downloader.purpose isEqualToString:kSuperAdminGetOrderKey])
    {
        [self.tableView headerEndRefreshing];

        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
 
            self.orderList = [dict objectForKey:@"orderList"];
            
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
}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
