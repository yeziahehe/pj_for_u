//
//  ConfirmOrderViewController.m
//  pj_for_u
//
//  Created by 缪宇青 on 15/8/6.
//  Copyright (c) 2015年 叶帆. All rights reserved.
//

#import "ConfirmOrderViewController.h"
#import "ShoppingCarTableViewCell.h"
#import "ShoppingCar.h"
#import "selectDeliverTimeView.h"

@interface ConfirmOrderViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *contentView;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UIView *payView;
@property (strong, nonatomic) IBOutlet UIView *deliverView;
@property (strong, nonatomic) IBOutlet UITableView *selectGoodsTableView;
@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) IBOutlet UIView *calculateView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) ShoppingCar *shoppingCarInfo;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *originPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneySavedLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliverTimeLabel;
@property (strong, nonatomic) UIView *background;


@end

@implementation ConfirmOrderViewController

#pragma mark - 键盘隐藏的一系列方法
//==========================================================
- (UIView *)background
{
    if (!_background) {
        _background = [[UIView alloc] init];
        _background.backgroundColor =  [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(removeFirstResponder)];
        singleTap.numberOfTapsRequired = 1;
        [_background addGestureRecognizer:singleTap];
    }
    
    return _background;
}

- (void)removeFirstResponder
{
    
    [self.background removeFromSuperview];
    [self cancelDeliverTimeNotification:nil];
    self.background = nil;
}

- (void)loadSubViews
{
    self.nameLabel.text = [MemberDataManager sharedManager].mineInfo.userInfo.nickname;
    self.phoneLabel.text = [MemberDataManager sharedManager].mineInfo.userInfo.phone;
    self.addressLabel.text = [MemberDataManager sharedManager].mineInfo.userInfo.defaultAddress;
    self.totalPriceLabel.text =  [NSString stringWithFormat:@"合计:%@",self.totalPrice];
    self.originPriceLabel.text = self.originPrice;
    self.moneySavedLabel.text = self.moneySaved;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(confirmDeliverTimeNotification:) name:kConfirmDeliverTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelDeliverTimeNotification:) name:kCancelDeliverTimeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)confirmDeliverTimeNotification:(NSNotification *)notification
{
    NSString *deliverTime = notification.object;
    self.deliverTimeLabel.text = deliverTime;
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[selectDeliverTimeView class]])
        {
            [subView removeFromSuperview];
            [self.background removeFromSuperview];
            self.background = nil;
        }
    }
}
- (void)cancelDeliverTimeNotification:(NSNotification *)notification
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[selectDeliverTimeView class]])
        {
            [subView removeFromSuperview];
            [self.background removeFromSuperview];
            self.background = nil;
        }
    }
}
- (IBAction)aLiPayButtonClicked:(id)sender {
}
- (IBAction)wechatButtonClicked:(id)sender {
}

- (IBAction)selectButtonClicked:(id)sender {
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[selectDeliverTimeView class]]) {
            [subView removeFromSuperview];
        }
    }
    selectDeliverTimeView *ctc = [[[NSBundle mainBundle]loadNibNamed:@"selectDeliverTimeView" owner:self options:nil]lastObject];
    CGRect rect = ctc.frame;
    rect.origin.y =  ScreenHeight-272.0f;
    rect.origin.x = 0.0f;
    rect.size.width = ScreenWidth;
    ctc.frame = rect;
    self.background.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:self.background];
    [self.view addSubview:ctc];
}

#pragma mark - UITableViewDataSoure methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.selectedArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"ShoppingCarTableViewCell";
    ShoppingCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ShoppingCarTableViewCell" owner:self options:nil];
        cell = [nibs lastObject];
    }
    cell.shoppingId = indexPath;
    self.shoppingCarInfo = [self.selectedArray objectAtIndex:indexPath.section];
    if (self.shoppingCarInfo) {
        cell.mainLabel.text = self.shoppingCarInfo.name;
        NSString *imageUrl = self.shoppingCarInfo.imageUrl;
        cell.YFImageView.cacheDir = kUserIconCacheDir;
        [cell.YFImageView aysnLoadImageWithUrl:imageUrl placeHolder:@"icon_user_default.png"];
        cell.discountPrice.text = [NSString stringWithFormat:@"%.1lf",[self.shoppingCarInfo.discountPrice floatValue]];
        cell.originPrice.text = [NSString stringWithFormat:@"原价:%.1lf",[self.shoppingCarInfo.price  floatValue]];
        cell.amount = [self.shoppingCarInfo.orderCount intValue];
        cell.orderCount.text = [NSString stringWithFormat:@"%d",cell.amount];
    }
    cell.PlusButton.enabled = NO;
    cell.MinusButton.enabled = NO;
        return cell;
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

@end
