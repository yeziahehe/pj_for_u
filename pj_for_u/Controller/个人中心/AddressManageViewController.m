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

#define kGetAddressDownloadKey      @"GetAddressDownloadKey"
#define kDeleteAddressDownloadKey   @"DeleteAddressDownloadKey"

@interface AddressManageViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *allAddressArray;
@property (strong,nonatomic)NSIndexPath *deleteIndex;
@end

@implementation AddressManageViewController

#pragma mark - Priavte Methods
- (void)loadSubView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    [[AddressDataManager sharedManager] requestForAddressWithPhoneId:phoneId];
}

#pragma mark - Notification Methods
- (void)refreshReciverInfoWithNotification:(NSNotification *)notification{
    [self loadSubView];
}

- (void)getAddressWithNotification:(NSNotification *)notification{
    NSArray *valueArray = notification.object;
    self.allAddressArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *valueDict in valueArray)
    {
        AddressInfo *hmm = [[AddressInfo alloc]initWithDict:valueDict];
        [self.allAddressArray addObject:hmm];
    }
    //如果只有一个收货地址，做设置默认地址处理
    if (self.allAddressArray.count == 1) {
        AddressInfo *firstAddress = [self.allAddressArray objectAtIndex:0];
        NSString *rank = firstAddress.rank;
        NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
        [[AddressDataManager sharedManager]requestToSetDefaultAddressWithPhontId:phoneId
                                                                            rank:rank];
    }
    [self.tableView reloadData];
}

- (void)deleteAddressWithNotification:(NSNotification *)notification
{
    [self loadSubView];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"我的收货地址"];
    [self loadSubView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshReciverInfoWithNotification:) name:kRefreshReciverInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAddressWithNotification:) name:kGetAddressNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshReciverInfoWithNotification:) name:kDeleteAddressNotification object:nil];
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
- (IBAction)addNewAdress:(id)sender
{
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
    if ([address.tag isEqualToString: @"0"])
    {
        UIColor *color = [UIColor colorWithRed:231.f/255 green:231.f/255 blue:231.f/255 alpha:1.f];
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

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //左滑删除地址数据
    AddressInfo *address = [self.allAddressArray objectAtIndex:indexPath.row];
    NSString *rank = address.rank;
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    [[AddressDataManager sharedManager]requestToDeleteReciverAddressWithPhoneId:phoneId
                                                                           rank:rank];
    [self.allAddressArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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

@end
