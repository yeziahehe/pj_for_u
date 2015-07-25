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

@end

@implementation SettingViewController

#pragma mark - Private Methods
- (void)loadSubViews
{
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:kSettingMapFileName ofType:@"plist"];
    self.menuArray = [NSArray arrayWithContentsOfFile:tempPath];
    self.settingTableView.tableFooterView = self.logoutView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviTitle:@"设置"];
    [self loadSubViews];
    self.phoneNum = @"18013646790";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonClicked:(UIButton *)sender
{
    [[MemberDataManager sharedManager] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];

    
}

#pragma mark - AlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (alertView.tag == 1) {
//        if (buttonIndex == 1)
//        {
//            [[MemberDataManager sharedManager] logout];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kUserChangeNotification object:nil];
//            [self.tabBarController setSelectedIndex:0];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }
//    else
    if (alertView.tag == 2)
    {
        if (buttonIndex == 1)
        {
            [[YFProgressHUD sharedProgressHUD] showMixedWithLoading:@"清除缓存..." end:@"清理完成"];
            [YFAppBackgroudConfiger clearAllCachesWhenBiggerThanSize:0];
        }
    }
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
    if ((indexPath.section ==2) && (indexPath.row ==1)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section ==3) {
         self.pushSwitch = [[UISwitch alloc] init];
        CGRect frame = self.pushSwitch.frame;
        frame.origin.x = ScreenWidth - 8 - frame.size.width;
        frame.origin.y = cell.center.y - frame.size.height/2;
        self.pushSwitch.frame = frame;
        [cell.contentView addSubview:self.pushSwitch];
    }
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
       return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *titleString = [[self.menuArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([titleString isEqualToString:@"清除缓存"])
    {
        if (IsIos8) {
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
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"是否清除缓存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 2;
            [alertView show];
        }
    }
    else if ([titleString isEqualToString:@"联系客服"])
    {
        NSString *phoneNum = @"18013646790";
        CallNumAndMessViewController *callNum = [[CallNumAndMessViewController alloc]init];
        callNum.phoneNum = phoneNum;
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
        if ([MemberDataManager sharedManager].loginMember.phone) {
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
