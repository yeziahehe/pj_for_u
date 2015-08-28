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
#import "AddressChooseViewController.h"

#define kGetDefaultAddressDownloaderKey     @"GetDefaultAddressDownloaderKey"
#define kOneKeyOrderDownloaderKey           @"OneKeyOrderDownloaderKey"
#define kUrlScheme      @"demoapp001" // 这个是你定义的 URL Scheme，支付宝、微信支付和测试模式需要。
#define kUrl            @"http://218.244.151.190/demo/charge" // 你的服务端创建并返回 charge 的 URL 地址，此地址仅供测试用。

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

@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) IBOutlet UIButton *aLiPayButton;
@property int select;      //1是支付宝，2是微信

@property (strong, nonatomic) IBOutlet UIButton *payButton;
@property (strong, nonatomic) UIButton *noAddressView;

@property BOOL isNotTrueTime;
@property (strong, nonatomic) NSMutableArray *timeArray;

@property (strong, nonatomic) NSMutableDictionary *indexPathBuffer;
@end

@implementation ConfirmOrderViewController

#pragma mark - Request Network
- (void)requestForEdit:(NSString *)orderId withOrderCount:(NSString *)orderCount
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kEditShoppingCarUrl];
    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phone forKey:@"phoneId"];
    [dict setObject:orderId forKey:@"orderId"];
    [dict setObject:orderCount forKey:@"orderCount"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kEditShoppingCarUrl];
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

//phoneId               手机号Id（required）
//orderId               订单号，多条以逗号隔开（required)
//rank                  用户收货人标识（required）
//reserveTime           预约时间,默认立即送达
//message               备注
//payWay                付款方式（required)0：未选择 1：支付宝 2：微信支付
//totalPrice            应付总价（required）
//preferentialId        满减种类
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
    [dict setObject:[NSString stringWithFormat:@"%d", self.select] forKey:@"payWay"];
    [dict setObject:self.totalPrice forKey:@"totalPrice"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kOneKeyOrderDownloaderKey];
}

//若在此页面未付款，则删除该订单
-(void)deleteOrder
{
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

#pragma mark - Private Method AND Initialize
- (NSMutableDictionary *)indexPathBuffer
{
    if (!_indexPathBuffer) {
        _indexPathBuffer = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _indexPathBuffer;
}

- (NSMutableArray *)timeArray
{
    if (!_timeArray) {
        _timeArray = [[NSMutableArray alloc] initWithCapacity:15];
    }
    return _timeArray;
}

- (UIButton *)noAddressView
{
    if (!_noAddressView) {
        _noAddressView = [[UIButton alloc] initWithFrame:self.addressView.frame];
        
        _noAddressView.backgroundColor = [UIColor whiteColor];
        
        [_noAddressView addTarget:self action:@selector(alterAddress:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [_noAddressView setTitle:@"暂无收货地址，点我添加" forState:UIControlStateNormal];
        [_noAddressView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [self.contentView addSubview:_noAddressView];
        
    }
    return _noAddressView;
    
}

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

- (void)requestForPay
{
    long long amount = [[self.totalPrice stringByReplacingOccurrencesOfString:@"." withString:@""] longLongValue];
    NSString *amountStr = [NSString stringWithFormat:@"%lld", amount];
    NSURL* url = [NSURL URLWithString:kUrl];
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* dict = @{
                           @"channel" : self.channel,
                           @"amount"  : amountStr
                           };
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString* charge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"charge = %@", charge);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Pingpp createPayment:charge viewController:self appURLScheme:kUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                NSLog(@"completion block: %@", result);
                if (error == nil) {
                    NSLog(@"PingppError is nil");
                } else {
                    NSLog(@"PingppError: code=%lu msg=%@", (unsigned  long)error.code, [error getMsg]);
                }
            }];
        });
    }];
    
}

//去除键盘和背景
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
    for (UIButton* b in buttonArray) {
        b.selected=NO;
    }
    button.selected=YES;
}

//添加订单总价
- (void)calculateTotalPrice
{
    self.totalPrice = nil;
    double price = 0.0;         //总价
    double singlePrice = 0.0;   //单价
    double cutMoneny = 0.0;     //省
    double cutFullPrice = 0.0;      //满
    double discountNum = 0.0;   //减
    for (ShoppingCar *sc in self.selectedArray) {
        
        if ([sc.isDiscount isEqualToString:@"1"]) {
            singlePrice = sc.discountPrice.doubleValue * sc.orderCount.intValue;
            double orignPrice = sc.price.doubleValue * sc.orderCount.intValue;
            cutMoneny += orignPrice - singlePrice;
            
        } else if ([sc.isDiscount isEqualToString:@"0"]) {
            singlePrice = sc.price.doubleValue * sc.orderCount.intValue;
        }
        price += singlePrice;
        
        if ([sc.isFullDiscount isEqualToString:@"1"]) {
            cutFullPrice += singlePrice;
            for (NSDictionary *dict in [MemberDataManager sharedManager].preferentials) {
                double full = [NSString stringWithFormat:@"%@", [dict objectForKey:@"needNumber"]].doubleValue;
                double cut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"discountNum"]].doubleValue;
                if (cutFullPrice >= full) {
                    discountNum = cut;
                    break;
                }
            }
        }
    }
    price -= discountNum;
    cutMoneny += discountNum;
    
    self.totalPrice = [NSString stringWithFormat:@"%.1f", price];
    self.totalPriceLabel.text =  [NSString stringWithFormat:@"合计:%.1f元", price];
    self.originPriceLabel.text = [NSString stringWithFormat:@"%.1f元", price + cutMoneny];
    self.moneySavedLabel.text = [NSString stringWithFormat:@"(已节省%.1f元)", cutMoneny];
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
    self.select = 1;
    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    [self requestForDefaultAddress:phone];
}

#pragma mark - IBAction  methords
//修改送货地址点击事件
- (IBAction)alterAddress:(UIButton *)sender
{
    AddressChooseViewController *address = [[AddressChooseViewController alloc] init];
    [self.navigationController pushViewController:address animated:YES];
}

//单选按钮点击事件
- (IBAction)buttonArrayClicked:(UIButton *)sender
{
    [self changeButtonState:sender buttons:self.buttonArray];
    switch (sender.tag) {
        case 1:
            self.select = 1;
            break;
        case 2:
            self.select = 2;
        default:
            break;
    }
}

//支付点击事件
- (IBAction)payButtonClicked:(id)sender
{
    
    if (self.isNotTrueTime) {
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"不是营业时间" hideDelay:2.f];
        return;
    }
    
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
    //    if (self.select == 1) {
    //        self.channel = @"alipay";
    //    }
    //    else
    //    {
    //        self.channel = @"wx";
    //    }
    //    [self requestForPay];
}

//选择送达时间点击事件
- (IBAction)selectButtonClicked:(id)sender
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[selectDeliverTimeView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    if (self.isNotTrueTime) {
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:@"不是营业时间" hideDelay:2.f];
        return;
    }
    
    selectDeliverTimeView *ctc = [[[NSBundle mainBundle]loadNibNamed:@"selectDeliverTimeView" owner:self options:nil] lastObject];
    
    //~~~~~~
    ctc.timeArray = self.timeArray;
    CGRect rect = ctc.frame;
    rect.origin.y =  ScreenHeight-272.0f;
    rect.origin.x = 0.0f;
    rect.size.width = ScreenWidth;
    ctc.frame = rect;
    self.background.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.navigationController.view addSubview:self.background];
    [self.navigationController.view addSubview:ctc];
}

#pragma mark - notification方法
//加号按钮监听事件
- (void)plusShoppingAmountNotification:(NSNotification *)notification
{
    NSIndexPath *shopId = notification.object;
    ShoppingCar *sc = [self.selectedArray objectAtIndex:shopId.section];
    //    if ([sc.orderCount intValue] > [sc.foodCount intValue]) {
    //        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"已增加到最大库存" customView:nil hideDelay:2.f];
    //    } else {

    [self.indexPathBuffer setObject:shopId forKey:@"indexPath"];
    [self.indexPathBuffer setObject:@"+" forKey:@"operand"];
    
    //}
    [self requestForEdit:sc.orderId withOrderCount:[NSString stringWithFormat:@"%d",[sc.orderCount intValue] + 1]];
}

//减号按钮监听事件
- (void)minusShoppingAmountNotification:(NSNotification *)notification
{
    NSIndexPath *shopId = notification.object;
    ShoppingCar *sc = [self.selectedArray objectAtIndex:shopId.section];
    if ([sc.orderCount isEqualToString:@"1"]) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"已减少到最小数量" customView:nil hideDelay:2.f];
    } else {
        [self.indexPathBuffer setObject:shopId forKey:@"indexPath"];
        [self.indexPathBuffer setObject:@"-" forKey:@"operand"];

        [self requestForEdit:sc.orderId withOrderCount:[NSString stringWithFormat:@"%d",[sc.orderCount intValue] - 1]];
    }
}

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

- (void)reloadAddress:(NSNotification *)notification
{
    if (notification.object) {
        NSDictionary *dict = (NSDictionary *)notification.object;
        self.nameLabel.text = [dict objectForKey:@"name"];
        self.phoneLabel.text = [dict objectForKey:@"phone"];
        self.addressLabel.text = [dict objectForKey:@"address"];
        
        self.noAddressView.hidden = YES;
        self.payButton.enabled  = YES;
        
    } else {
        self.noAddressView.hidden = NO;
        self.payButton.enabled  = NO;
    }
}

- (void)reloadDeliverView:(NSNotification *)notification
{
    if (notification.object) {
        [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:notification.object hideDelay:2.f];
    } else {
        NSDictionary *dict = [MemberDataManager sharedManager].homeInfo;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *nowString = [dateFormatter stringFromDate:nowDate];
        NSString *openTime = [NSString stringWithFormat:@"%@ %@", nowString, [dict objectForKey:@"openTime"]];
        NSString *closeTime = [NSString stringWithFormat:@"%@ %@", nowString, [dict objectForKey:@"closeTime"]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *openDate = [dateFormatter dateFromString:openTime];
        NSDate *closeDate = [dateFormatter dateFromString:closeTime];
        
        
        if ([nowDate compare:closeDate] == NSOrderedDescending) {
            //不是营业时间
            self.isNotTrueTime = YES;
        } else {
            self.isNotTrueTime = NO;
            NSDate *tempDate = [nowDate compare:openDate] == NSOrderedDescending?[NSDate dateWithTimeIntervalSinceNow:3600]:closeDate;
            [dateFormatter setDateFormat:@"HH:mm"];
            NSInteger interval = 60*60;
            
            if ([nowDate compare:openDate] != NSOrderedAscending) {
                [self.timeArray addObject:@"立即送达"];
            }
            
            while ([tempDate compare:closeDate] != NSOrderedDescending) {
                NSString *time = [dateFormatter stringFromDate:tempDate];
                [self.timeArray addObject:time];
                tempDate = [NSDate dateWithTimeInterval:interval sinceDate:tempDate];
                if ([tempDate compare:closeDate] == NSOrderedDescending) {
                    time = [dateFormatter stringFromDate:closeDate];
                    [self.timeArray addObject:time];
                    break;
                }
            }
        }
    }
}

//确认送达时间监听事件
- (void)confirmDeliverTimeNotification:(NSNotification *)notification
{
    NSString *deliverTime = notification.object;
    self.deliverTimeLabel.text = deliverTime;
    for (UIView *subView in self.navigationController.view.subviews) {
        if ([subView isKindOfClass:[selectDeliverTimeView class]]) {
            [UIView animateWithDuration:0.2
                 animations:^{
                     
                     [subView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, subView.frame.size.height)];
                 }
                 completion:^(BOOL finished){
                     if (finished) {
                         [subView removeFromSuperview];
                         [self.background removeFromSuperview];
                         self.background = nil;
                     }
                 }];
            
        }
    }
}

//取消送达事件监听事件
- (void)cancelDeliverTimeNotification:(NSNotification *)notification
{
    for (UIView *subView in self.navigationController.view.subviews) {
        if ([subView isKindOfClass:[selectDeliverTimeView class]]) {
            [UIView animateWithDuration:0.2
                 animations:^{
                     
                     [subView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, subView.frame.size.height)];
                 }
                 completion:^(BOOL finished){
                     if (finished) {
                         [subView removeFromSuperview];
                         [self.background removeFromSuperview];
                         self.background = nil;
                     }
                 }];
        }
    }
}

#pragma mark - ViewController Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviTitle:@"确认订单"];
    
    [self loadSubViews];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(confirmDeliverTimeNotification:) name:kConfirmDeliverTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelDeliverTimeNotification:) name:kCancelDeliverTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAddress:) name:kChooseAddressNoticfication object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(plusShoppingAmountNotification:) name:kPlusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(minusShoppingAmountNotification:) name:kMinusShoppingAmountNotification object:nil];
    
    [[MemberDataManager sharedManager] getHomeCateGoryInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDeliverView:) name:kGetHomeInfoNotification object:nil];
    
    [self.payButton setEnabled:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
    
    if ([self.buyNowFlag isEqualToString:@"1"]) {
        [self deleteOrder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
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
        
        if ([self.shoppingCarInfo.isFullDiscount isEqualToString:@"1"]) {
            cell.preferential.hidden = NO;
            cell.cutImageView.hidden = NO;
            NSMutableString *preferentialString = [[NSMutableString alloc] initWithCapacity:30];
            for (NSDictionary *dict in [MemberDataManager sharedManager].preferentials) {
                NSString *full = [NSString stringWithFormat:@"%@", [dict objectForKey:@"needNumber"]];
                NSString *cut = [NSString stringWithFormat:@"%@", [dict objectForKey:@"discountNum"]];
                [preferentialString appendString:[NSString stringWithFormat:@"满%@减%@;", full, cut]];
            }
            cell.preferential.text = preferentialString;
        } else {
            cell.preferential.hidden = YES;
            cell.cutImageView.hidden = YES;
        }

        cell.amount = [self.shoppingCarInfo.orderCount intValue];
        cell.orderCount.text = [NSString stringWithFormat:@"%d",cell.amount];
    }
    cell.PlusButton.enabled = YES;
    cell.MinusButton.enabled = YES;
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
            
            if (self.defaultReceiver) {
                self.noAddressView.hidden = YES;
                self.nameLabel.text = self.defaultReceiver;
                self.phoneLabel.text = self.defaultRecPhone;
                self.addressLabel.text = self.defaultAddress;
                [self.payButton setEnabled:YES];
            } else {
                self.noAddressView.hidden = NO;
                [self.payButton setEnabled:NO];
            }
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
            
            
            [Pingpp createPayment:[dict objectForKey:@"charge"]
                   viewController:self
                     appURLScheme:kUrlScheme
                   withCompletion:^(NSString *result, PingppError *error) {
                       if ([result isEqualToString:@"success"]) {
                           // 支付成功
                           
                           
                       } else {
                           // 支付失败或取消
                           
                           

                           NSLog(@"Error: code=%lu msg=%@", error.code, [error getMsg]);
                       }
                   }];
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
    else if ([downloader.purpose isEqualToString:kEditShoppingCarUrl])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            //成功
            NSIndexPath *indexPath = [self.indexPathBuffer objectForKey:@"indexPath"];
            NSString *operand = [self.indexPathBuffer objectForKey:@"operand"];
            ShoppingCar *sc = [self.selectedArray objectAtIndex:indexPath.section];
            if ([operand isEqualToString:@"+"]) {
                sc.orderCount = [NSString stringWithFormat:@"%d",[sc.orderCount intValue] + 1];
            } else if ([operand isEqualToString:@"-"]) {
                sc.orderCount = [NSString stringWithFormat:@"%d",[sc.orderCount intValue] - 1];
            }
            [self calculateTotalPrice];

            [self.selectGoodsTableView reloadData];

        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
            if(message.length == 0)
                message = @"修改数量失败";
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
