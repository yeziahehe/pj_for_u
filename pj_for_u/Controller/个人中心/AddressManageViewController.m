//
//  AddressManageViewController.m
//  pj_for_u
//
//  Created by MiY on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "AddressManageViewController.h"
#import "AddressManageTableViewCell.h"
#import "AddReciverViewController.h"
#import "AddressInfo.h"
#import "LoginViewController.h"

#define kGetAddressDownloadKey  @"GetAddressDownloadKey"
@interface AddressManageViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *allAddressArray;
@end

@implementation AddressManageViewController

#pragma mark - Priavte Methods
- (void)requestForAddress
{
    [[YFProgressHUD sharedProgressHUD] startedNetWorkActivityWithText:@"加载中"];
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    if (nil == phoneId) {
        phoneId = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetReciverUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetAddressDownloadKey];
}

- (void)loadSubView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self requestForAddress];
}
#pragma mark - Notification Methods
- (void)refreshReciverInfoWithNotification:(NSNotification *)notification{
    [self loadSubView];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"我的收货地址"];
    [self loadSubView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshReciverInfoWithNotification:) name:kRefreshReciverInfoNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - IBAction Methods
- (IBAction)addNewAdress:(id)sender {
    AddReciverViewController *avc = [[AddReciverViewController alloc]initWithNibName:@"AddReciverViewController" bundle:nil];
    [self.navigationController pushViewController:avc animated:YES];
    avc.NavTitle = @"新增收货地址";
    avc.tagNew = @"0";
}

#pragma mark - UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressManageTableViewCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AddressManageTableViewCell" owner:self options:nil] lastObject];
    }
    AddressInfo *address = [self.allAddressArray objectAtIndex:indexPath.row];
    cell.name.text = address.name;
    cell.phoneNum.text = address.phone;
    cell.address.text = address.address;
    cell.campusId = address.campusId;
    cell.campusName = address.campusName;
    if ([address.tag isEqualToString: @"0"]) {
        UIColor *color = [UIColor colorWithRed:36.f/255 green:233.f/255 blue:194.f/255 alpha:1.f];
        cell.backgroundColor = color;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allAddressArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddReciverViewController *avc = [[AddReciverViewController alloc]initWithNibName:@"AddReciverViewController" bundle:nil];
    [self.navigationController pushViewController:avc animated:YES];
    avc.NavTitle = @"修改收货地址";
    AddressInfo *address = [self.allAddressArray objectAtIndex:indexPath.row];
    avc.tagNew = @"1";
    avc.reciverName = address.name;
    avc.reciverPhone = address.phone;
    avc.addressDetail = address.address;
    avc.reciverRank = address.rank;
    avc.reciverCampusId = address.campusId;
    avc.reciverCampusName = address.campusName;
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetAddressDownloadKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            self.allAddressArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"receivers"];
            for (NSDictionary *valueDict in valueArray) {
                AddressInfo *hmm = [[AddressInfo alloc]initWithDict:valueDict];
                [self.allAddressArray addObject:hmm];
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
                message = @"获取地址失败,请稍后再试";
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
