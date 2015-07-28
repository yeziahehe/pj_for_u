//
//  SettingViewController.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/23.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "AboutAppViewController.h"
#import "ResetPwdViewController.h"
#import "ForgetPwdViewController.h"

#define kSettingMapFileName         @"SettingMap"

@interface SettingViewController ()
@property (nonatomic, strong) NSArray *menuArray;
@end

@implementation SettingViewController

#pragma mark - Private Methods
- (void)loadSubViews
{
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:kSettingMapFileName ofType:@"plist"];
    self.menuArray = [NSArray arrayWithContentsOfFile:tempPath];
    [self refreshSetting];
}

- (void)refreshSetting
{
    if ([[MemberDataManager sharedManager] isLogin])
    {
        self.settingTableView.tableFooterView = self.logoutView;
    }
    else
    {
        self.settingTableView.tableFooterView = [UIView new];
    }
    [self.settingTableView reloadData];
}

#pragma mark - IBAction Methods
- (IBAction)logoutButtonClicked:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出"
                                                                   message:@"确定退出登录？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                [[MemberDataManager sharedManager] logout];
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangeNotification object:nil];
                                                [self.tabBarController setSelectedIndex:0];
                                                [self.navigationController popToRootViewControllerAnimated:YES];
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"设置"];
    [self loadSubViews];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.menuArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.menuArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"SettingTableViewCell";
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"SettingTableViewCell" owner:self options:nil];
        cell = [nibs lastObject];
    }
    
    NSString *titleString = [[self.menuArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    cell.titleLabel.text = titleString;
    
    if ((indexPath.section == 1))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ((indexPath.section == 2) && (indexPath.row == 1))
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8.f;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *titleString = [[self.menuArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([titleString isEqualToString:@"清除缓存"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除缓存"
                                                                       message:@"是否清除缓存？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [[YFProgressHUD sharedProgressHUD] showMixedWithLoading:@"清除缓存..." end:@"清理完成"];
                                                    [YFAppBackgroudConfiger clearAllCachesWhenBiggerThanSize:0];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([titleString isEqualToString:@"联系客服"])
    {
        UIAlertController *phonenumSheet = [UIAlertController alertControllerWithTitle:@"1111111" message:@"这是一个电话号码，您要对它：" preferredStyle:UIAlertControllerStyleActionSheet];
        [phonenumSheet addAction:[UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                        }]];
        [phonenumSheet addAction:[UIAlertAction actionWithTitle:@"拨打电话"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            //打电话
                                                            UIAlertController *phonealert = [UIAlertController alertControllerWithTitle:nil
                                                                                                                                message:@"11111"
                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                                            [phonealert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                                                                           style:UIAlertActionStyleDefault
                                                                                                         handler:^(UIAlertAction *action) {
                                                                                                             //什么都不做
                                                                                                         }]];
                                                            [phonealert addAction:[UIAlertAction actionWithTitle:@"拨打"
                                                                                                           style:UIAlertActionStyleDefault
                                                                                                         handler:^(UIAlertAction *action) {
                                                                                                             NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",@"1111"]];
                                                                                                             [[UIApplication sharedApplication] openURL:telURL];
                                                                                                         }]];
                                                            [self presentViewController:phonealert animated:YES completion:nil];
                                                        }]];
        [self presentViewController:phonenumSheet animated:YES completion:nil];
    }
    else if ([titleString isEqualToString:@"关于我们"])
    {
        AboutAppViewController *aboutAppViewController = [[AboutAppViewController alloc]initWithNibName:@"AboutAppViewController" bundle:nil];
        [self.navigationController pushViewController:aboutAppViewController animated:YES];
    }
    else if ([titleString isEqualToString:@"给我评分"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:kAppRateUrl, kAppAppleId]]];
    }
    else if ([titleString isEqualToString:@"修改密码"])
    {
        if ([MemberDataManager sharedManager].loginMember.phone)
        {
            ResetPwdViewController *rpvc = [[ResetPwdViewController alloc]initWithNibName:@"ResetPwdViewController" bundle:nil];
            [self.navigationController pushViewController:rpvc animated:YES];
        } else {
            ForgetPwdViewController *fpvc = [[ForgetPwdViewController alloc]initWithNibName:@"ForgetPwdViewController" bundle:nil];
            [self.navigationController pushViewController:fpvc animated:YES];
        }
    }
}

@end
