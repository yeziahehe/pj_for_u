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
#import "CampusMoel.h"

@interface AddressManageViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *allAddressArray;
@property (strong, nonatomic)NSIndexPath *deleteIndex;
@property (strong, nonatomic)NSString *phoneId;

@end

@implementation AddressManageViewController

#pragma mark - Priavte Methods
- (void)loadSubView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [[AddressDataManager sharedManager] requestForAddressWithPhoneId:self.phoneId];
}

#pragma mark - Notification Methods
- (void)refreshReciverInfoWithNotification:(NSNotification *)notification{
    [self loadSubView];
}

- (void)getAddressWithNotification:(NSNotification *)notification{
    NSArray *valueArray = notification.object;
    self.allAddressArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *valueDict in valueArray) {
        AddressInfo *hmm = [[AddressInfo alloc]initWithDict:valueDict];
        [self.allAddressArray addObject:hmm];
    }
    //如果只有一个收货地址，做设置默认地址处理
    if(self.allAddressArray.count != 0) {
        AddressInfo *firstAddress = [self.allAddressArray objectAtIndex:0];
        NSString *rank = firstAddress.rank;
        [[AddressDataManager sharedManager] requestToSetDefaultAddressWithPhontId:self.phoneId rank:rank];
    }
    
    CGFloat height = 160 + self.allAddressArray.count * 60;
    [self.scrollView setContentSize:CGSizeMake(ScreenWidth, height)];
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.phoneId = [MemberDataManager sharedManager].loginMember.phone;
    [self loadSubView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshReciverInfoWithNotification:) name:kRefreshReciverInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAddressWithNotification:) name:kGetAddressNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteAddressWithNotification:) name:kDeleteAddressNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
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
    cell.rank = address.rank;
    cell.campusId = address.campusId;
    if ([address.tag isEqualToString: @"0"])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    [[AddressDataManager sharedManager]requestToDeleteReciverAddressWithPhoneId:self.phoneId
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
    avc.addressDetail = [address.address stringByReplacingOccurrencesOfString:address.campusName withString:@""];;
    avc.reciverRank = address.rank;
    avc.reciverCampusId = address.campusId;
    avc.reciverCampusName = address.campusName;
}

@end
