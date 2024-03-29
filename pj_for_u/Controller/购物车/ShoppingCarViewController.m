//
//  ShoppingCarViewController.m
//  HDemo
//
//  Created by 缪宇青 on 15/8/1.
//  Copyright (c) 2015年 缪宇青. All rights reserved.
//

#import "ShoppingCarViewController.h"
#import "ShoppingCarTableViewCell.h"
#import "ShoppingCar.h"
#import "ConfirmOrderViewController.h"
#import "ProductDetailViewController.h"

#define kGetShoppingCarDownloaderKey    @"GetShoppingCarDownloaderKey"
#define kEditShoppingCarDownloaderKey   @"EditShoppingCarDownloaderKey"
#define kDeleteShoppingCarDownloaderKey   @"DeleteShoppingCarDownloaderKey"

@interface ShoppingCarViewController ()
@property (strong, nonatomic) IBOutlet UITableView *ShoppingCarTableView;
@property (strong, nonatomic) IBOutlet UIView *deleteShoppingCarView;
@property (strong, nonatomic) IBOutlet UIView *noOrderView;
@property (strong, nonatomic) IBOutlet UIView *CalculateView;
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountPrice;
@property (strong, nonatomic) IBOutlet UILabel *moneySavedLabel;
@property (strong, nonatomic) ShoppingCar *shoppingCarInfo;
@property (strong, nonatomic) NSMutableArray *shoppingTempArray;
@property (strong, nonatomic) NSMutableArray *shoppingCarArray;
@property (strong, nonatomic) NSMutableArray *shoppingCarSelectedArray;
@property (strong, nonatomic) UIView *backGrayView;
@property (strong, nonatomic) NSString *totalPrice;
@property (strong, nonatomic) NSString *originPrice;
@property (strong, nonatomic) NSString *disCount;
@property BOOL isChangedToSelectMode;


@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *payButton;

@property (strong, nonatomic) NSMutableDictionary *indexPathBuffer;

@end
@implementation ShoppingCarViewController

#pragma mark - Private Method AND Initialize
//懒加载
- (NSMutableDictionary *)indexPathBuffer
{
    if (!_indexPathBuffer) {
        _indexPathBuffer = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    return _indexPathBuffer;
}

- (NSMutableArray *)shoppingCarArray
{
    if (!_shoppingCarArray) {
        _shoppingCarArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _shoppingCarArray;
}

- (NSMutableArray *)shoppingCarSelectedArray
{
    if (!_shoppingCarSelectedArray) {
        _shoppingCarSelectedArray = [[NSMutableArray alloc]initWithCapacity:0];
            }
    return _shoppingCarSelectedArray;
}

//初始化不存在订单的购物车界面
- (void)noGoodsExistView
{
    [self setRightNaviItemWithTitle:@"" imageName:nil];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    self.shoppingCarArray = nil;
    CGRect rect = self.noOrderView.frame;
    rect.size.height = ScreenHeight;
    rect.size.width = ScreenWidth;
    self.noOrderView.frame = rect;
    [[self.goAroundButton layer] setCornerRadius:5];
    [[self.goAroundButton layer] setBorderWidth:0.5];
    [[self.goAroundButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.view addSubview:self.noOrderView];
}

//下拉刷新方法
- (void)dropDownRefresh
{
    self.shoppingCarSelectedArray = nil;
    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    [self requestForShoppingCar:phone];
}

//计算订单总价
- (void)calculateTotalPrice
{
    NSMutableArray *calculateArray = [[NSMutableArray alloc]init];
    if (!self.isChangedToSelectMode) {
        calculateArray = self.shoppingCarArray;
    }
    else
    {
        calculateArray = self.shoppingCarSelectedArray;
        if ([calculateArray count] == 0) {
            self.totalPriceLabel.text = @"合计:0.0元";
            self.discountPrice.text = @"0.0元";
            self.moneySavedLabel.text =@"(已节省0.0元)";
        }
    }
    
    if ([calculateArray count] != 0) {
        self.totalPrice = nil;
        self.originPrice = nil;
        self.disCount = nil;
        
        double price = 0.0;         //总价
        double singlePrice = 0.0;   //单价
        double cutMoneny = 0.0;     //省
        double cutFullPrice = 0.0;      //满
        double discountNum = 0.0;   //减
        for (ShoppingCar *sc in calculateArray) {
            
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
        
        self.totalPrice = [NSString stringWithFormat:@"%.1f元", price];
        self.originPrice = [NSString stringWithFormat:@"%.1f元", price + cutMoneny];
        self.disCount = [NSString stringWithFormat:@"(已节省%.1f元)", cutMoneny];
        self.totalPriceLabel.text =  [NSString stringWithFormat:@"合计:%@", self.totalPrice];
        self.discountPrice.text = self.originPrice;
        self.moneySavedLabel.text = self.disCount;
    }
}


//初始化数据
- (void)loadSubViews
{
    self.navigationItem.leftBarButtonItem = nil;
    [self.ShoppingCarTableView addHeaderWithTarget:self action:@selector(dropDownRefresh)];
}

#pragma mark - IBAction methods
//购物车删除按钮点击事件
- (IBAction)deleteShoppingCar:(id)sender
{
    NSMutableString *orderId = [[NSMutableString alloc]initWithCapacity:0];
    if (self.shoppingCarSelectedArray) {
        for (int i = 0;i < [self.shoppingCarSelectedArray count];i++) {
            ShoppingCar *sc = [self.shoppingCarSelectedArray objectAtIndex:i];
            if (i == 0) {
                [orderId appendFormat:@"%@",sc.orderId];
            }
            else {
                [orderId appendFormat:@",%@",sc.orderId];
            }
        }
    }
    NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
    [self requestForDelete:phone orderId:orderId];
    orderId = nil;
    self.shoppingCarSelectedArray = nil;
    self.backGrayView.hidden = NO;
    self.deleteShoppingCarView.hidden = YES;
}

//随便逛逛按钮点击事件
- (IBAction)goAroundButtonClicked:(id)sender
{
    self.tabBarController.selectedIndex = 0;
}

//结算按钮点击事件
- (IBAction)calculateButtonClicked:(id)sender
{
    ConfirmOrderViewController *confirmOrder = [[ConfirmOrderViewController alloc] initWithNibName:@"ConfirmOrderViewController" bundle:nil];
    if (self.isChangedToSelectMode) {
        confirmOrder.selectedArray = self.shoppingCarSelectedArray;
    }
    else {
        confirmOrder.selectedArray = self.shoppingCarArray;
    }
    [self.navigationController pushViewController:confirmOrder animated:YES];
    self.shoppingCarSelectedArray = nil;
}

#pragma mark - notification方法
//加号按钮监听事件
- (void)plusShoppingAmountNotification:(NSNotification *)notification
{
    NSIndexPath *shopId = notification.object;
    ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:shopId.section];
//    if ([sc.orderCount intValue] > [sc.foodCount intValue]) {
//        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"已增加到最大库存" customView:nil hideDelay:2.f];
//    } else {
    //}
    [self.indexPathBuffer setObject:shopId forKey:@"indexPath"];
    [self.indexPathBuffer setObject:@"+" forKey:@"operand"];
    
    //}
    [self requestForEdit:sc.orderId withOrderCount:[NSString stringWithFormat:@"%d",[sc.orderCount intValue] + 1]];
}

//减号按钮监听事件
- (void)minusShoppingAmountNotification:(NSNotification *)notification
{
    NSIndexPath *shopId = notification.object;
    ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:shopId.section];
    if ([sc.orderCount isEqualToString:@"1"]) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"已减少到最小数量" customView:nil hideDelay:2.f];
    } else {
        [self.indexPathBuffer setObject:shopId forKey:@"indexPath"];
        [self.indexPathBuffer setObject:@"-" forKey:@"operand"];
        
        [self requestForEdit:sc.orderId withOrderCount:[NSString stringWithFormat:@"%d",[sc.orderCount intValue] - 1]];
    }
}

//移除darkgreyview监听事件
- (void)removeBackGrayViewNotification:(NSNotification *)notification
{
    NSIndexPath *cellId = notification.object;
    ShoppingCarTableViewCell *cell = (ShoppingCarTableViewCell *)[self.ShoppingCarTableView cellForRowAtIndexPath:cellId];
    ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:cellId.section];
    if ([self.shoppingCarSelectedArray count] == 0) {
        [self.CalculateView addSubview:self.deleteShoppingCarView];
        self.deleteShoppingCarView.hidden = NO;
        [self.CalculateView addSubview:self.totalPriceLabel];
        [self.CalculateView addSubview:self.moneySavedLabel];
    }
    [self.shoppingCarSelectedArray addObject:sc];
    NSLog(@"选择后，选择的数量为： %lu",(unsigned long)self.shoppingCarSelectedArray.count);
    if ([self.shoppingCarSelectedArray count] > 0) {
        self.backGrayView.hidden = YES;
    }
    cell.isSelected = YES;
    cell.backGrayView.hidden = YES;
    [self calculateTotalPrice];
}

#pragma mark - ViewController Lifecycle
//视图出现前调用,依据是否登录判断显示界面
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSubViews];
    [self noGoodsExistView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.deleteButton setEnabled:NO];
    [self.payButton setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(plusShoppingAmountNotification:) name:kPlusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(minusShoppingAmountNotification:) name:kMinusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeBackGrayViewNotification:) name:kRemoveBackGrayViewNotification object:nil];
    
    if ([[MemberDataManager sharedManager] isLogin]) {
        NSString *phone = [MemberDataManager sharedManager].loginMember.phone;
        [self requestForShoppingCar:phone];
        [self.ShoppingCarTableView reloadData];
        [self.backGrayView removeFromSuperview];
        self.isChangedToSelectMode = NO;
        self.shoppingCarSelectedArray = nil;
        self.deleteShoppingCarView.hidden = YES;
        [self.ShoppingCarTableView reloadData];
        [self calculateTotalPrice];
    }
    else
    {
        [self noGoodsExistView];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[YFDownloaderManager sharedManager] cancelDownloaderWithDelegate:self purpose:nil];
}

#pragma mark - ViewController methods
- (void)rightItemTapped
{
    if(self.isChangedToSelectMode) {
        [self.backGrayView removeFromSuperview];
        self.isChangedToSelectMode = NO;
        self.shoppingCarSelectedArray = nil;
        [self setRightNaviItemWithTitle:@"选择" imageName:nil];
        self.deleteShoppingCarView.hidden = YES;
        [self.ShoppingCarTableView reloadData];
        [self calculateTotalPrice];
    } else {
        self.totalPriceLabel.text = @"合计:0.0元";
        self.discountPrice.text = @"0.0元";
        self.moneySavedLabel.text =@"(已节省0.0元)";
        [self setRightNaviItemWithTitle:@"完成" imageName:nil];
        self.isChangedToSelectMode = YES;
        [self.ShoppingCarTableView reloadData];
        self.backGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 120.f)];
        self.backGrayView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        [self.CalculateView addSubview:self.backGrayView];
        self.deleteShoppingCarView.hidden = NO;
    }
}


#pragma mark - UITableViewDataSoure methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.shoppingCarArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShoppingCar *car = [self.shoppingCarArray objectAtIndex:indexPath.section];
    BOOL select =  [self.shoppingCarSelectedArray containsObject:car];
    static NSString *cellIdentity = @"ShoppingCarTableViewCell";
    static NSString *selectCellIdentity = @"selectShoppingCarTableViewCell";
    NSString *selectString;
    if (select) {
        selectString = selectCellIdentity;
    } else {
        selectString = cellIdentity;
    }
    ShoppingCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectString];

    if (nil == cell) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ShoppingCarTableViewCell" owner:self options:nil];
        cell = [nibs lastObject];
    }
    cell.shoppingId = indexPath;
    self.shoppingCarInfo = [self.shoppingCarArray objectAtIndex:indexPath.section];
    if (self.shoppingCarInfo) {
        cell.mainLabel.text = self.shoppingCarInfo.name;
        NSString *imageUrl = self.shoppingCarInfo.imageUrl;
        cell.YFImageView.cacheDir = kUserIconCacheDir;
        [cell.YFImageView aysnLoadImageWithUrl:imageUrl placeHolder:@"icon_user_default.png"];
        if ([self.shoppingCarInfo.isDiscount isEqualToString:@"1"]) {
            cell.originPrice.text = [NSString stringWithFormat:@"原价:%.1lf",[self.shoppingCarInfo.price  floatValue]];
            cell.discountPrice.text = [NSString stringWithFormat:@"%.1lf",[self.shoppingCarInfo.discountPrice floatValue]];
        } else {
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
        
        cell.secondLabel.text = self.shoppingCarInfo.message;
        cell.amount = [self.shoppingCarInfo.orderCount intValue];
        cell.orderCount.text = [NSString stringWithFormat:@"%d",cell.amount];
    }
    
    if (self.isChangedToSelectMode) {
        if (!select) {
            cell.backGrayView.hidden = NO;
        }
        cell.PlusButton.enabled = NO;
        cell.MinusButton.enabled = NO;
    }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.isChangedToSelectMode) {
        ShoppingCarTableViewCell *cell = (ShoppingCarTableViewCell *)[self.ShoppingCarTableView cellForRowAtIndexPath:indexPath];
        ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:indexPath.section];
        [self.shoppingCarSelectedArray removeObject:sc];
        cell.backGrayView.hidden = NO;
        [self calculateTotalPrice];
        NSLog(@"移除后，物品的数量为：%lu",(unsigned long)self.shoppingCarSelectedArray.count);
        if ([self.shoppingCarSelectedArray count] == 0) {
            self.deleteShoppingCarView.hidden = YES;
            self.backGrayView.hidden = NO;
        }
        if ([self.shoppingCarSelectedArray count] > 0) {
            self.backGrayView.hidden = YES;
        }
    } else {
        ProductDetailViewController *detail = [[ProductDetailViewController alloc]init];
        self.shoppingCarInfo = [self.shoppingCarArray objectAtIndex:indexPath.section];
        detail.foodId = self.shoppingCarInfo.foodId;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

//删除购物车请求
- (void)requestForDelete:(NSString *)phone orderId:(NSString *)orderId
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kDeleteShoppingCarUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phone forKey:@"phoneId"];
    [dict setObject:orderId forKey:@"orderId"];
    
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kDeleteShoppingCarDownloaderKey];
}

//修改订单数量请求
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
                                                                purpose:kEditShoppingCarDownloaderKey];
}

//请求购物车数据
- (void)requestForShoppingCar:(NSString *)phone
{
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中"];
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetShoppingCarUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phone forKey:@"phoneId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kGetShoppingCarDownloaderKey];
}

#pragma mark - YFDownloaderDelegate Methods
- (void)downloader:(YFDownloader *)downloader completeWithNSData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *dict = [str JSONValue];
    if ([downloader.purpose isEqualToString:kGetShoppingCarDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            self.shoppingCarArray = nil;
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            NSArray *valueArray = [dict objectForKey:@"orderList"];
            for (NSDictionary *valueDict in valueArray) {
                ShoppingCar *shoppingCar = [[ShoppingCar alloc] initWithDict:valueDict];
                [self.shoppingCarArray addObject:shoppingCar];
            }
            [self.ShoppingCarTableView headerEndRefreshing];
            if([self.shoppingCarArray count] == 0)
            {
                [self noGoodsExistView];
            }
            else
            {
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
                [self setRightNaviItemWithTitle:@"选择" imageName:nil];

                [self.noOrderView removeFromSuperview];
            }
            [self calculateTotalPrice];
            
            [self.ShoppingCarTableView reloadData];
            [self.deleteButton setEnabled:YES];
            [self.payButton setEnabled:YES];

        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
            
            if(message.length == 0)
                message = @"获取购物车信息失败";
            
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kEditShoppingCarDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            //成功
            NSIndexPath *indexPath = [self.indexPathBuffer objectForKey:@"indexPath"];
            NSString *operand = [self.indexPathBuffer objectForKey:@"operand"];
            ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:indexPath.section];
            if ([operand isEqualToString:@"+"]) {
                sc.orderCount = [NSString stringWithFormat:@"%d",[sc.orderCount intValue] + 1];
            } else if ([operand isEqualToString:@"-"]) {
                sc.orderCount = [NSString stringWithFormat:@"%d",[sc.orderCount intValue] - 1];
            }
            [self calculateTotalPrice];

            [self.ShoppingCarTableView reloadData];

        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
    
            if(message.length == 0)
                message = @"修改数量失败";
            
            [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:message hideDelay:2.f];
        }
    }
    else if ([downloader.purpose isEqualToString:kDeleteShoppingCarDownloaderKey])
    {
        if([[dict objectForKey:kCodeKey] isEqualToString:kSuccessCode])
        {
            //成功
            [self.shoppingCarArray removeObjectsInArray:self.shoppingCarSelectedArray];
            [self.ShoppingCarTableView headerBeginRefreshing];
            [self.shoppingCarSelectedArray removeAllObjects];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
                message = @"";
            
            if(message.length == 0)
                message = @"删除订单失败";
            
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
