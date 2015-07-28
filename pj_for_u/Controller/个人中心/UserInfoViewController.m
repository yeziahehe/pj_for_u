//
//  UserInfoViewController.m
//  pj_for_u
//
//  Created by 叶帆 on 15/7/22.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "UserInfoViewController.h"
#import "IndividualViewController.h"
#import "SettingViewController.h"
#import "AddressManageViewController.h"

@interface UserInfoViewController ()
@property (strong, nonatomic) IBOutlet YFAsynImageView *headPhoto;
@property (strong, nonatomic) IBOutlet YFAsynImageView *headBackPhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IndividualInfo *individualInfo;
@property (strong, nonatomic) UIVisualEffectView *effectView;

@end

@implementation UserInfoViewController

#pragma mark - Private Methods
- (void)loadSubViews
{
    if ([[MemberDataManager sharedManager] isLogin])
    {
        self.nameLabel.text = self.individualInfo.userInfo.nickname;
        if (![self.individualInfo.userInfo.imgUrl isEqualToString:@""]) {
            self.headPhoto.cacheDir = kUserIconCacheDir;
            [self.headPhoto aysnLoadImageWithUrl:self.individualInfo.userInfo.imgUrl placeHolder:@"icon_user_default.png"];
            // 毛玻璃效果，仅适用于ios8 and later
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            self.effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
            self.effectView.frame = self.headBackPhoto.frame;
            [self.headBackPhoto addSubview:self.effectView];
            self.headBackPhoto.cacheDir = kUserIconCacheDir;
            [self.headBackPhoto aysnLoadImageWithUrl:self.individualInfo.userInfo.imgUrl placeHolder:@"bg_user_img.png"];
        }
        else {
            [self.headPhoto setImage:[UIImage imageNamed:@"icon_user_default"]];
            [self.headBackPhoto setImage:[UIImage imageNamed:@"bg_user_img"]];
            [self.effectView removeFromSuperview];
        }
    } else {
        self.nameLabel.text = @"点击登录";
        [self.headPhoto setImage:[UIImage imageNamed:@"icon_user_default"]];
        [self.headBackPhoto setImage:[UIImage imageNamed:@"bg_user_img"]];
        [self.effectView removeFromSuperview];
    }
}

- (void)addImageBorder
{
    CALayer *layer = [self.headPhoto layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 2.7f;
    self.headPhoto.layer.masksToBounds = YES;
    self.headPhoto.layer.cornerRadius = (self.headPhoto.bounds.size.width) / 2.f;
}

#pragma mark - IBAction Methods
- (IBAction)LoginButtonClicked:(id)sender {
    if ([[MemberDataManager sharedManager] isLogin]) {
        //do nothing
    } else {
        //登录
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }
}

- (IBAction)addressManage:(UIButton *)sender
{
    if ([[MemberDataManager sharedManager] isLogin]) {
        //地址管理页面
        AddressManageViewController *addressManageViewController = [[AddressManageViewController alloc] init];
        [self.navigationController pushViewController:addressManageViewController animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }
}

- (IBAction)myOrder:(id)sender
{
    if ([[MemberDataManager sharedManager] isLogin]) {
        //我的订单页面
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }
}

- (IBAction)individualInfo:(UIButton *)sender
{
    if ([[MemberDataManager sharedManager] isLogin]) {
        //个人信息页面
        IndividualViewController *individualViewController = [[IndividualViewController alloc] init];
        [self.navigationController pushViewController:individualViewController animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }
}

- (IBAction)setting:(UIButton *)sender
{
    //设置页面
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController animated:YES];
}

#pragma mark - NSNotification Methods
- (void)userChangeWithNotification:(NSNotification *)notification
{
    [self extraItemTapped];
    if ([[MemberDataManager sharedManager] isLogin])
    {
        [[MemberDataManager sharedManager] requestForIndividualInfoWithPhone:[MemberDataManager sharedManager].loginMember.phone];
    } else {
        [self loadSubViews];
    }
}

- (void)refreshUserInfoWithNotification:(NSNotification *)notification
{
    [[MemberDataManager sharedManager] requestForIndividualInfoWithPhone:[MemberDataManager sharedManager].loginMember.phone];
}

- (void)userInfoResponseWithNotification:(NSNotification *)notification
{
    if (notification.object) {
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"个人信息获取失败" hideDelay:2.f];
    } else {
        self.individualInfo = [MemberDataManager sharedManager].mineInfo;
        [self loadSubViews];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAccoutNotification object:nil];
    }
}

#pragma mark - UIViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addImageBorder];
    
    if ([[MemberDataManager sharedManager] isLogin]) {
        [[MemberDataManager sharedManager] requestForIndividualInfoWithPhone:[MemberDataManager sharedManager].loginMember.phone];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangeWithNotification:) name:kUserChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfoWithNotification:) name:kRefreshUserInfoNotificaiton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoResponseWithNotification:) name:kUserInfoResponseNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

@end
