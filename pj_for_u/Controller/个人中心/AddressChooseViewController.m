//
//  AddressChooseViewController.m
//  pj_for_u
//
//  Created by MiY on 15/8/19.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "AddressChooseViewController.h"
#import "AddressManageTableViewCell.h"
#import "AddressManageViewController.h"
#import "AddressInfo.h"

@interface AddressChooseViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *allAddressArray;


@end

@implementation AddressChooseViewController

- (void)getAddressNotification:(NSNotification *)notification
{
    NSArray *valueArray = notification.object;
    
    self.allAddressArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *valueDict in valueArray)
    {
        AddressInfo *hmm = [[AddressInfo alloc] initWithDict:valueDict];
        [self.allAddressArray addObject:hmm];
    }
    
    [self.tableView reloadData];


}

- (void)rightItemTapped
{
    AddressManageViewController *amvc = [[AddressManageViewController alloc] init];
    [self.navigationController pushViewController:amvc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"选择收货地址"];
    [self setRightNaviItemWithTitle:@"管理" imageName:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAddressNotification:) name:kGetAddressNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AddressDataManager sharedManager] requestForAddressWithPhoneId:[MemberDataManager sharedManager].loginMember.phone];

}

- (void)viewWillDisappear:(BOOL)animated
{
    for (int i = 0; i < self.allAddressArray.count; i++) {
        NSIndexPath *indexPathTemp = [NSIndexPath indexPathForRow:i inSection:0];
        AddressManageTableViewCell *cell = (AddressManageTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPathTemp];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
            [dict setObject:cell.name.text forKey:@"name"];
            [dict setObject:cell.phoneNum.text forKey:@"phone"];
            [dict setObject:cell.address.text forKey:@"address"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kChooseAddressNoticfication object:dict];
            return;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kChooseAddressNoticfication object:nil];


}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

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
    cell.accessoryType = UITableViewCellAccessoryNone;
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


#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (int i = 0; i < self.allAddressArray.count; i++) {
        NSIndexPath *indexPathTemp = [NSIndexPath indexPathForRow:i inSection:0];
        AddressManageTableViewCell *cell = (AddressManageTableViewCell *)[tableView cellForRowAtIndexPath:indexPathTemp];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    AddressManageTableViewCell *cell = (AddressManageTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.f;
}

@end
