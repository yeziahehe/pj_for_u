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
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) ShoppingCar *shoppingCarInfo;
@property (strong, nonatomic) NSMutableArray *shoppingCarArray;
@property (strong, nonatomic) NSMutableArray *shoppingTempArray;
@property (strong, nonatomic) NSMutableArray *shoppingCarSelectedArray;
@property (strong, nonatomic) UIView *backGrayView;
@property (strong, nonatomic) NSString *totalPrice;
@property (strong, nonatomic) NSString *originPrice;
@property (strong, nonatomic) NSString *disCount;
@property (strong, nonatomic) NSString *type;
@property BOOL isChangedToSelectMode;
@property int page;

@end
@implementation ShoppingCarViewController
//懒加载
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
    self.type = @"1";
    self.page = 1;
    NSString *pageString = [NSString stringWithFormat:@"%d",self.page];
    [self requestForShoppingCar:@"18896554880" page:pageString limit:@"3"];
}
//上拉刷新方法
- (void)pullUpRefresh
{
    self.type = @"2";
    self.page ++;
    NSString *pageString = [NSString stringWithFormat:@"%d",self.page];
    [self requestForShoppingCar:@"18896554880" page:pageString limit:@"3"];
}

//添加订单总价
- (void)calculateTotalPrice
{
    self.totalPrice = nil;
    self.originPrice = nil;
    self.disCount = nil;
    for (int i = 0; i < self.shoppingCarSelectedArray.count; i++) {
        ShoppingCar *sc = [self.shoppingCarSelectedArray objectAtIndex:i];
        self.totalPrice = [NSString stringWithFormat:@"%.1f元",[self.totalPrice floatValue]+[sc.discountPrice floatValue]*[sc.orderCount intValue]];
        self.originPrice = [NSString stringWithFormat:@"%.1f元",[self.originPrice floatValue]+[sc.price floatValue]*[sc.orderCount intValue]];
        self.disCount = [NSString stringWithFormat:@"(已节省%.1f元)",[self.originPrice floatValue]-[self.totalPrice floatValue]];
    }
    self.totalPriceLabel.text = self.totalPrice;
    self.discountPrice.text = self.originPrice;
    self.moneySavedLabel.text = self.disCount;
}


//初始化数据
- (void)loadSubViews
{
    self.navigationItem.leftBarButtonItem = nil;
    self.isChangedToSelectMode = NO;
    self.page = 1;
    self.type = @"1";
    self.shoppingCarSelectedArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.deleteShoppingCarView.hidden = YES;
    [self.ShoppingCarTableView addHeaderWithTarget:self action:@selector(dropDownRefresh)];
    [self.ShoppingCarTableView addFooterWithTarget:self action:@selector(pullUpRefresh)];
    [self setRightNaviItemWithTitle:@"选择" imageName:nil];
}
//视图出现前调用,依据是否登录判断显示界面
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[MemberDataManager sharedManager] isLogin]) {
        if ([self.shoppingCarArray count] == 0) {
            [self.noOrderView removeFromSuperview];
            [self.ShoppingCarTableView headerBeginRefreshing];
            [self.ShoppingCarTableView reloadData];
        }
    }
    else
    {
        [self noGoodsExistView];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(plusShoppingAmountNotification:) name:kPlusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(minusShoppingAmountNotification:) name:kMinusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeBackGrayViewNotification:) name:kRemoveBackGrayViewNotification object:nil];
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
#pragma mark - UIViewController methods
- (void)rightItemTapped
{
    if(self.isChangedToSelectMode)
    {
        [self.backGrayView removeFromSuperview];
        self.isChangedToSelectMode = NO;
        [self setRightNaviItemWithTitle:@"选择" imageName:nil];
        self.deleteShoppingCarView.hidden = YES;
        [self.ShoppingCarTableView reloadData];
        self.totalPriceLabel.text = @"0.0元";
        self.discountPrice.text = @"0.0元";
        self.moneySavedLabel.text =@"(已节省0.0元)";
    }
    else
    {
        [self setRightNaviItemWithTitle:@"完成" imageName:nil];
        self.isChangedToSelectMode = YES;
        [self.ShoppingCarTableView reloadData];
        self.backGrayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 120.f)];
        self.backGrayView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        [self.CalculateView addSubview:self.backGrayView];
        self.deleteShoppingCarView.hidden = NO;
        [self.CalculateView addSubview:self.deleteShoppingCarView];
        [self.CalculateView addSubview:self.totalPriceLabel];
        [self.CalculateView addSubview:self.moneySavedLabel];
        [self.CalculateView addSubview:self.totalLabel];
    }
}

#pragma mark - IBAction methods
- (IBAction)deleteShoppingCar:(id)sender {
    NSMutableString *orderId = [[NSMutableString alloc]initWithCapacity:0];
    if (self.shoppingCarSelectedArray) {
        for (int i = 0;i < [self.shoppingCarSelectedArray count];i++) {
            ShoppingCar *sc = [self.shoppingCarSelectedArray objectAtIndex:i];
            if (i == 0) {
                [orderId appendFormat:@"%@",sc.orderId];
            }
            else{
                [orderId appendFormat:@",%@",sc.orderId];
            }
        }
    }
    [self requestForDelete:@"18896554880" orderId:orderId];
    orderId = nil;
}

- (IBAction)goAroundButtonClicked:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)calculateButtonClicked:(id)sender {
    ConfirmOrderViewController *confirmOrder = [[ConfirmOrderViewController alloc]initWithNibName:@"ConfirmOrderViewController" bundle:nil];
    [self.navigationController pushViewController:confirmOrder animated:YES];
}

#pragma mark - notification方法
- (void)plusShoppingAmountNotification:(NSNotification *)notification{
    NSIndexPath *shopId = notification.object;
    ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:shopId.section];
//    if ([sc.orderCount intValue] > [sc.foodCount intValue]) {
//        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"已增加到最大库存" customView:nil hideDelay:2.f];
//    } else {
        sc.orderCount = [NSString stringWithFormat:@"%d",[sc.orderCount intValue]+1];
    //}
    [self.ShoppingCarTableView reloadData];
    [self requestForEdit:sc.orderId withOrderCount:sc.orderCount];
}
- (void)minusShoppingAmountNotification:(NSNotification *)notification{
    NSIndexPath *shopId = notification.object;
    ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:shopId.section];
    if ([sc.orderCount isEqualToString:@"1"]) {
        [[YFProgressHUD sharedProgressHUD] showWithMessage:@"已减少到最小数量" customView:nil hideDelay:2.f];
    }
    else{
    sc.orderCount = [NSString stringWithFormat:@"%d",[sc.orderCount intValue]-1];
    [self.ShoppingCarTableView reloadData];
    [self requestForEdit:sc.orderId withOrderCount:sc.orderCount];
    }
}
- (void)removeBackGrayViewNotification:(NSNotification *)notification
{
    NSIndexPath *cellId = notification.object;
    ShoppingCarTableViewCell *cell = (ShoppingCarTableViewCell *)[self.ShoppingCarTableView cellForRowAtIndexPath:cellId];
    ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:cellId.section];
    [self.shoppingCarSelectedArray addObject:sc];
    cell.isSelected = YES;
    cell.backGrayView.hidden = YES;
    [self calculateTotalPrice];
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
    static NSString *cellIdentity = @"ShoppingCarTableViewCell";
    ShoppingCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (nil == cell)
    {
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
        cell.discountPrice.text = [NSString stringWithFormat:@"%.1lf",[self.shoppingCarInfo.discountPrice floatValue]];
        cell.originPrice.text = [NSString stringWithFormat:@"原价:%.1lf",[self.shoppingCarInfo.price  floatValue]];
        cell.amount = [self.shoppingCarInfo.orderCount intValue];
        cell.orderCount.text = [NSString stringWithFormat:@"%d",cell.amount];
    }
    
    if (self.isChangedToSelectMode) {
        if (!cell.isSelected) {
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
    if(self.isChangedToSelectMode)
    {
        ShoppingCarTableViewCell *cell = (ShoppingCarTableViewCell *)[self.ShoppingCarTableView cellForRowAtIndexPath:indexPath];
        ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:indexPath.section];
        [self.shoppingCarSelectedArray removeObject:sc];
        cell.backGrayView.hidden = NO;
        if ([self.shoppingCarSelectedArray count] == 0) {
            self.totalPriceLabel.text = @"0.0元";
            self.discountPrice.text = @"0.0元";
            self.moneySavedLabel.text =@"(已节省0.0元)";
        }
        else{
            [self calculateTotalPrice];
        }
    }
    else{
        ProductDetailViewController *detail = [[ProductDetailViewController alloc]init];
        self.shoppingCarInfo = [self.shoppingCarArray objectAtIndex:indexPath.section];
        detail.foodId = self.shoppingCarInfo.foodId;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)requestForDelete:(NSString *)phone
                 orderId:(NSString *)orderId
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
- (void)requestForEdit:(NSString *)orderId
        withOrderCount:(NSString *)orderCount
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kEditShoppingCarUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:@"18896554880" forKey:@"phoneId"];
    [dict setObject:orderId forKey:@"orderId"];
    [dict setObject:orderCount forKey:@"orderCount"];


    [[YFDownloaderManager sharedManager] requestDataByPostWithURLString:url
                                                             postParams:dict
                                                            contentType:@"application/x-www-form-urlencoded"
                                                               delegate:self
                                                                purpose:kEditShoppingCarDownloaderKey];
    

}
- (void)requestForShoppingCar:(NSString *)phone
                         page:(NSString *)page
                        limit:(NSString *)limit
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kGetShoppingCarUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:phone forKey:@"phoneId"];
    [dict setObject:kCampusId forKey:@"campusId"];
    [dict setObject:page forKey:@"page"];
    [dict setObject:limit forKey:@"limit"];
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
            self.shoppingTempArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"orderList"];
            for (NSDictionary *valueDict in valueArray) {
                ShoppingCar *shoppingCar = [[ShoppingCar alloc] initWithDict:valueDict];
                [self.shoppingTempArray addObject:shoppingCar];
            }
            if ([self.type isEqualToString:@"1"]) {
                self.shoppingCarArray = self.shoppingTempArray;
                [self.ShoppingCarTableView headerEndRefreshing];
            }
            else if([self.type isEqualToString:@"2"])
            {
                [self.shoppingCarArray addObjectsFromArray:self.shoppingTempArray];
                [self.ShoppingCarTableView footerEndRefreshing];
            }
            if([self.shoppingCarArray count] == 0)
            {
                [self noGoodsExistView];
            }
            [self.ShoppingCarTableView reloadData];
        }
        else
        {
            NSString *message = [dict objectForKey:kMessageKey];
            if ([message isKindOfClass:[NSNull class]])
            {
                message = @"";
            }
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
            {
                message = @"";
            }
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
