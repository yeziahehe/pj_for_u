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
#import "CallNumAndMessViewController.h"
#import "ResetPwdViewController.h"
#import "ForgetPwdViewController.h"

#define kSettingMapFileName         @"SettingMap"

@interface SettingViewController ()
@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, strong) UISwitch *pushSwitch;
@property (nonatomic, strong) NSString *phoneNum;
@property  BOOL remote;
@end

@implementation SettingViewController

#pragma mark - Private Methods
//加载plist文件的设置选项，并初始化客服电话和推送状态
- (void)loadSubViews
{
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:kSettingMapFileName ofType:@"plist"];
    self.menuArray = [NSArray arrayWithContentsOfFile:tempPath];
    self.settingTableView.tableFooterView = self.logoutView;
    [self setNaviTitle:@"设置"];
    self.phoneNum = @"18013646790";
    self.remote = [self checkRemoteNotificationType];
}

//获取当前设备的推送状态
- (BOOL)checkRemoteNotificationType
{
    UIRemoteNotificationType types;
        types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;

        return (types & UIRemoteNotificationTypeAlert);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods
//退出登录按钮点击事件
- (IBAction)logoutButtonClicked:(UIButton *)sender
{
    [[MemberDataManager sharedManager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    if (indexPath.section == 3)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
         self.pushSwitch = [[UISwitch alloc] init];
        CGRect frame = self.pushSwitch.frame;
        frame.origin.x = ScreenWidth - 8 - frame.size.width;
        frame.origin.y = cell.center.y - frame.size.height/2;
        self.pushSwitch.frame = frame;
        [self.pushSwitch setOn:self.remote];
        [cell.contentView addSubview:self.pushSwitch];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

//根据点击不同的cell触发不同事件
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
        CallNumAndMessViewController *callNum = [[CallNumAndMessViewController alloc]init];
        callNum.phoneNum = self.phoneNum;
        callNum.useViewController = self;
        [callNum clickPhone];
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
        }
    else{
            ForgetPwdViewController *fpvc = [[ForgetPwdViewController alloc]initWithNibName:@"ForgetPwdViewController" bundle:nil];
            [self.navigationController pushViewController:fpvc animated:YES];
        }
    }
    else if ([titleString isEqualToString:@"是否推送"])
    {
        
    }
}

@end
