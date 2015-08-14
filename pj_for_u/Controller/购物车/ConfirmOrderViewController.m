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
#import "AddressManageViewController.h"

#define kGetDefaultAddressDownloaderKey     @"GetDefaultAddressDownloaderKey"
#define kOneKeyOrderDownloaderKey           @"OneKeyOrderDownloaderKey"

@interface ConfirmOrderViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArray;
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
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *deliverButton;
@property (strong, nonatomic) IBOutlet UILabel *deliverTimeLabel;
@property (strong, nonatomic) UIView *background;
@property (strong, nonatomic) NSString *defaultAddress;
@property (strong, nonatomic) NSString *defaultRecPhone;
@property (strong, nonatomic) NSString *defaultReceiver;
@property (strong, nonatomic) NSString *defaultRank;
@property (strong, nonatomic) NSString *totalPrice;
@property (strong, nonatomic) NSString *originPrice;
@property (strong, nonatomic) NSString *moneySaved;
@property (strong, nonatomic) IBOutlet UIButton *aLiPayButton;
@property BOOL select;

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
- (void)touchScrollView
{
    [self.descriptionTextView resignFirstResponder];
}

//改变单选按钮状态方法
-(void)changeButtonState:(UIButton *)button buttons:(NSArray *)buttonArray
{
    for (UIButton* b in buttonArray)
        
    {
        b.selected=NO;
    }
    button.selected=YES;
}

//添加订单总价
- (void)calculateTotalPrice
{
        self.totalPrice = nil;
        self.originPrice = nil;
        self.moneySaved = nil;
        for (int i = 0; i < [self.selectedArray count]; i++) {
            ShoppingCar *sc = [self.selectedArray objectAtIndex:i];
            if ([sc.isDiscount isEqualToString:@"1"]) {
                self.totalPrice = [NSString stringWithFormat:@"%.1f元",[self.totalPrice floatValue]+[sc.discountPrice floatValue]*[sc.orderCount intValue]];
            }
            else{
                self.totalPrice = [NSString stringWithFormat:@"%.1f元",[self.totalPrice floatValue]+[sc.price floatValue]*[sc.orderCount intValue]];
            }
            self.originPrice = [NSString stringWithFormat:@"%.1f元",[self.originPrice floatValue]+[sc.price floatValue]*[sc.orderCount intValue]];
            self.moneySaved = [NSString stringWithFormat:@"(已节省%.1f元)",[self.originPrice floatValue]-[self.totalPrice floatValue]];
        }
        self.totalPriceLabel.text =  [NSString stringWithFormat:@"合计:%@",self.totalPrice];
        self.originPriceLabel.text = self.originPrice;
        self.moneySavedLabel.text = self.moneySaved;
}

//加载scrollView
- (void)loadSubViews
{
    [self calculateTotalPrice];
    CGFloat originY = 0.f;
    CGRect rect = self.addressView.frame;
    rect.origin.x = 0.f;
    rect.origin.y = originY;
    rect.size.height = 113.f;
    rect.size.width = ScreenWidth;
    originY = originY + 122.f;
    self.addressView.frame = rect;
    
    rect = self.selectGoodsTableView.frame;
    rect.origin.x = 0;
    rect.origin.y = originY;
    rect.size.height = [self.selectedArray count]*150.f;
    rect.size.width = ScreenWidth;
    self.selectGoodsTableView.frame = rect;
    originY = 131.f + rect.size.height;
    
    rect = self.deliverView.frame;
    rect.origin.x = 0;
    rect.origin.y = originY;
    rect.size.height = 44.f;
    rect.size.width = ScreenWidth;
    self.deliverView.frame = rect;
    originY = originY + 53.f;
    
    rect = self.payView.frame;
    rect.origin.x = 0;
    rect.origin.y = originY;
    rect.size.height = 106.f;
    rect.size.width = ScreenWidth;
    self.payView.frame = rect;
    originY = originY + 115.f;
    
    rect = self.descriptionView.frame;
    rect.origin.x = 0;
    rect.origin.y = originY;
    rect.size.height = 72.f;
    rect.size.width = ScreenWidth;
    self.descriptionView.frame = rect;
    originY = originY + 81.f;
    
    rect = self.calculateView.frame;
    rect.origin.x = 0;
    rect.origin.y = originY;
    rect.size.height = 82.f;
    rect.size.width = ScreenWidth;
    self.calculateView.frame = rect;
    originY = originY + 91.f;

    [self.contentView addSubview:self.addressView];
    [self.contentView addSubview:self.selectGoodsTableView];
    [self.contentView addSubview:self.deliverView];
    [self.contentView addSubview:self.payView];
    [self.contentView addSubview:self.descriptionView];
    [self.contentView addSubview:self.calculateView];
    [self.contentView setContentSize:CGSizeMake(ScreenWidth, originY)];
    
    self.contentView.delegate = self;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchScrollView)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self.contentView addGestureRecognizer:recognizer];
    self.aLiPayButton.selected = YES;
    self.select = YES;
    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    [[YFProgressHUD sharedProgressHUD]startedNetWorkActivityWithText:@"加载中"];
    [self requestForDefaultAddress:phone];
}
//若在此页面未付款，则删除该订单
-(void)deleteOrder{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //接口地址
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kDeleteSmallOrderUrl];
    //传递参数存放的字典
    NSString *phoneId = [MemberDataManager sharedManager].loginMember.phone;
    ShoppingCar *sc = [self.selectedArray objectAtIndex:0];
    NSString *orderId = sc.orderId;
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:orderId forKey:@"orderId"];
    
    //进行post请求
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        NSLog(@"未付款，删除成功");
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if ([self.buyNowFlag isEqualToString:@"1"]) {
        [self deleteOrder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(confirmDeliverTimeNotification:) name:kConfirmDeliverTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelDeliverTimeNotification:) name:kCancelDeliverTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - Notification methords
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.deliverButton.enabled = NO;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat originYY = self.calculateView.frame.origin.y;
    [self.contentView setContentOffset:CGPointMake(0, originYY- (ScreenHeight - keyboardSize.height - self.calculateView.frame.size.height) + 10)];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.deliverButton.enabled = YES;
    CGFloat originYY = self.calculateView.frame.origin.y;
    [self.contentView setContentOffset:CGPointMake(0,originYY + self.calculateView.frame.size.height - ScreenHeight + 10)];
}
//确认送达时间监听事件
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
//取消送达事件监听事件
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

#pragma mark - IBAction  methords
//修改送货地址点击事件
- (IBAction)alterAddress:(UIButton *)sender {
    AddressManageViewController *address = [[AddressManageViewController alloc]init];
    [self.navigationController pushViewController:address animated:YES];
}

//单选按钮点击事件
- (IBAction)buttonArrayClicked:(UIButton *)sender {
    [self changeButtonState:sender buttons:self.buttonArray];
    switch (sender.tag) {
        case 1:
            self.select = YES;
            break;
        case 2:
            self.select = NO;
        default:
            break;
    }
}

//支付点击事件
- (IBAction)payButtonClicked:(id)sender {
    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    NSMutableString *orderId = [[NSMutableString alloc]initWithCapacity:0];
    if (self.selectedArray) {
        for (int i = 0;i < [self.selectedArray count];i++) {
            ShoppingCar *sc = [self.selectedArray objectAtIndex:i];
            if (i == 0) {
                [orderId appendFormat:@"%@",sc.orderId];
            }
            else{
                [orderId appendFormat:@",%@",sc.orderId];
            }
        }
    }
    [self requestForOneKeyOrder:phone orderId:orderId rank:self.defaultRank reserveTime:self.deliverTimeLabel.text message:self.descriptionTextView.text];
    orderId = nil;
}
//选择送达时间点击事件
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
        if ([self.shoppingCarInfo.isDiscount isEqualToString:@"1"]) {
            cell.originPrice.text = [NSString stringWithFormat:@"原价:%.1lf",[self.shoppingCarInfo.price  floatValue]];
            cell.discountPrice.text = [NSString stringWithFormat:@"%.1lf",[self.shoppingCarInfo.discountPrice floatValue]];
        }
        else
        {
            cell.discountPrice.text = [NSString stringWithFormat:@"%.1lf",[self.shoppingCarInfo.price floatValue]];
            cell.originPrice.hidden = YES;
            cell.discountLine.hidden = YES;
        }
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

- (void)requestForDefaultAddress:(NSString *)phoneId
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetDefaultAddressUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetDefaultAddressDownloaderKey];
}
//phoneId      手机号Id（required）
//orderId      订单号，多条以逗号隔开（required)
//rank      用户收货人标识（required）
//reserveTime      预约时间,默认立即送达
//message      备注
- (void)requestForOneKeyOrder:(NSString *)phoneId
                      orderId:(NSString *)orderId
                         rank:(NSString *)rank
                  reserveTime:(NSString *)reserveTime
                      message:(NSString *)message
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kOneKeyOrderUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phoneId forKey:@"phoneId"];
    [dict setObject:orderId forKey:@"orderId"];
    [dict setObject:rank forKey:@"rank"];
    [dict setObject:reserveTime forKey:@"reserveTime"];
    [dict setObject:message forKey:@"message"];

    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kOneKeyOrderDownloaderKey];
}
#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetDefaultAddressDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            [[YFProgressHUD sharedProgressHUD]stoppedNetWorkActivity];
            NSArray *valueArray = [dict objectForKey:@"receivers"];
            for (NSDictionary *valueDict in valueArray) {
                NSString *lm = [NSString stringWithFormat:@"%@",[valueDict objectForKey:@"tag"]];
                if ([lm isEqualToString:@"0"]) {
                    self.defaultReceiver = [valueDict objectForKey:@"name"];
                    self.defaultRecPhone = [valueDict objectForKey:@"phone"];
                    self.defaultAddress = [valueDict objectForKey:@"address"];
                    self.defaultRank = [valueDict objectForKey:@"rank"];
                }
            }
            self.nameLabel.text = self.defaultReceiver;
            self.phoneLabel.text = self.defaultRecPhone;
            self.addressLabel.text = self.defaultAddress;
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"获取默认地址失败";
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kOneKeyOrderDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            //成功
            NSLog(@"下单成功");
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"下单失败";
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
