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
#import "MyOrderViewController.h"

#import "BigManageViewController.h"
#import "CourierViewController.h"

@interface UserInfoViewController ()
@property (strong, nonatomic) IBOutlet YFAsynImageView *headPhoto;
@property (strong, nonatomic) IBOutlet YFAsynImageView *headBackPhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IndividualInfo *individualInfo;
@property (strong, nonatomic) UIVisualEffectView *effectView;
@property (strong, nonatomic) UIImage *previousImage;

@property (strong, nonatomic) IBOutlet UIButton *courierButton;     //派送员
@property (strong, nonatomic) IBOutlet UIButton *bigManageButton;     //大经理

@end

@implementation UserInfoViewController

#pragma mark - Private Methods
- (UIVisualEffectView *)effectView      //懒加载，这样比较方便
{
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
        CGRect frame = self.headBackPhoto.frame;
        frame.size.width = ScreenWidth;
        self.effectView.frame = frame;
    }
    return _effectView;
}

- (void)loadSubViews
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage)];
    if ([[MemberDataManager sharedManager] isLogin])
    {
        self.nameLabel.text = self.individualInfo.userInfo.nickname;
        if (![self.individualInfo.userInfo.imgUrl isEqualToString:@""]) {
            if (self.previousImage != nil) {
                [self.headPhoto aysnLoadImageWithUrl:[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl placeHolderImage:self.previousImage];
                [self.headPhoto addGestureRecognizer:tap];
            } else {
                [self.headPhoto aysnLoadImageWithUrl:[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl placeHolder:@"icon_user_default.png"];
                [self.headPhoto addGestureRecognizer:tap];
            }
            // 毛玻璃效果，仅适用于ios8 and later
            [self.headBackPhoto addSubview:self.effectView];
            if (self.previousImage != nil) {
                [self.headBackPhoto aysnLoadImageWithUrl:[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl placeHolderImage:self.previousImage];
            } else {
                [self.headBackPhoto aysnLoadImageWithUrl:[MemberDataManager sharedManager].mineInfo.userInfo.imgUrl placeHolder:@"bg_user_img.png"];
            }
        }
        else {
            [self.headPhoto setImage:[UIImage imageNamed:@"icon_user_default"]];
            [self.headBackPhoto setImage:[UIImage imageNamed:@"bg_user_img"]];
            [self.effectView removeFromSuperview];
            [self.headPhoto removeGestureRecognizer:tap];
        }
    } else {
        self.nameLabel.text = @"点击登录";
        [self.headPhoto setImage:[UIImage imageNamed:@"icon_user_default"]];
        [self.headBackPhoto setImage:[UIImage imageNamed:@"bg_user_img"]];
        [self.effectView removeFromSuperview];
        [self.headPhoto removeGestureRecognizer:tap];
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

- (void)magnifyImage {
    [YFPhotoBrower showImage:self.headPhoto];
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
        MyOrderViewController *myOrderViewController = [[MyOrderViewController alloc] init];
        [self.navigationController pushViewController:myOrderViewController animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginViewNotification object:nil];
    }
}

- (IBAction)individualInfo:(UIButton *)sender
{
    if ([[MemberDataManager sharedManager] isLogin]) {
        //个人信息页面
        IndividualViewController *individualViewController = [[IndividualViewController alloc] init];
        individualViewController.photoImage = self.headPhoto.image;
        individualViewController.backPhotoImage = self.headBackPhoto.image;
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
    self.previousImage = self.headPhoto.image;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangeWithNotification:) name:kUserChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfoWithNotification:) name:kRefreshUserInfoNotificaiton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoResponseWithNotification:) name:kUserInfoResponseNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.courierButton.hidden = YES;
    self.bigManageButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//左侧返回按钮，文字的颜色
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    if ([[MemberDataManager sharedManager] isLogin]) {
        [[MemberDataManager sharedManager] requestForIndividualInfoWithPhone:[MemberDataManager sharedManager].loginMember.phone];
        
        if ([[MemberDataManager sharedManager].loginMember.type isEqualToString:@"0"]) {
            
            self.bigManageButton.hidden = NO;
            [self.bigManageButton addTarget:self action:@selector(bigManageAction) forControlEvents:UIControlEventTouchUpInside];
            
        } else if ([[MemberDataManager sharedManager].loginMember.type isEqualToString:@"1"]) {
            
            self.courierButton.hidden = NO;
            [self.courierButton addTarget:self action:@selector(courierAction) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else {
            self.courierButton.hidden = YES;
            self.bigManageButton.hidden = YES;
        }
    }
}

- (void)courierAction
{
    CourierViewController *cvc = [[CourierViewController alloc] init];
    [self.navigationController pushViewController:cvc animated:YES];
}


- (void)bigManageAction
{
    BigManageViewController *bmvc = [[BigManageViewController alloc] init];
    [self.navigationController pushViewController:bmvc animated:YES];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

@end
