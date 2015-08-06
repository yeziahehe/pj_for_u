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
@property (strong, nonatomic) ShoppingCar *shoppingCarInfo;
@property (strong, nonatomic) NSMutableArray *shoppingCarArray;
@property (strong, nonatomic) NSMutableArray *shoppingTempArray;
@property (strong, nonatomic) IBOutlet UIView *noOrderView;
@property (strong, nonatomic) IBOutlet UIView *CalculateView;
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;
@property (strong, nonatomic) NSString *totalPrice;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountPrice;
@property (strong, nonatomic) IBOutlet UILabel *moneySavedLabel;
@property int page;
@property (strong, nonatomic) NSString *type;

@property BOOL isChangedToSelectMode;
@end
@implementation ShoppingCarViewController

- (NSMutableArray *)shoppingCarArray
{
    if (!_shoppingCarArray) {
        _shoppingCarArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _shoppingCarArray;
}
- (void)loadSubViews
{
    //初始化界面为购物车中没有商品
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

- (void)dropDownRefresh
{
    self.type = @"1";
    self.page = 1;
    NSString *pageString = [NSString stringWithFormat:@"%d",self.page];
    [self requestForShoppingCar:@"18896554880" page:pageString limit:@"3"];
}
- (void)pullUpRefresh
{
    self.type = @"2";
    self.page ++;
    NSString *pageString = [NSString stringWithFormat:@"%d",self.page];
    [self requestForShoppingCar:@"18896554880" page:pageString limit:@"3"];
}

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
        [self loadSubViews];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isChangedToSelectMode = NO;
    self.page = 1;
    self.type = @"1";
    [self.ShoppingCarTableView addHeaderWithTarget:self action:@selector(dropDownRefresh)];
    [self.ShoppingCarTableView addFooterWithTarget:self action:@selector(pullUpRefresh)];
    [self setRightNaviItemWithTitle:@"选择" imageName:nil];
        //[self.ShoppingCarTableView headerBeginRefreshing];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(plusShoppingAmountNotification:) name:kPlusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(minusShoppingAmountNotification:) name:kMinusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeBackGrayViewNotification:) name:kRemoveBackGrayViewNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightItemTapped
{
    if(self.isChangedToSelectMode)
    {
        self.isChangedToSelectMode = NO;
        [self setRightNaviItemWithTitle:@"选择" imageName:nil];
        [self.ShoppingCarTableView reloadData];
    }
    else
    {
        [self setRightNaviItemWithTitle:@"完成" imageName:nil];
        self.isChangedToSelectMode = YES;
        [self.ShoppingCarTableView reloadData];
    }
}

#pragma mark - IBAction methods
- (IBAction)goAroundButtonClicked:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)calculateButtonClicked:(id)sender {
    for (int i = 0; i < self.shoppingCarArray.count; i++) {
        ShoppingCar *sc = [self.shoppingCarArray objectAtIndex:i];
            self.totalPrice = [NSString stringWithFormat:@"%.1f元",[self.totalPrice floatValue]+[sc.discountPrice floatValue]*[sc.orderCount intValue]];
    }
    self.totalPriceLabel.text = self.totalPrice;
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
    cell.backGrayView.hidden = YES;
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
        cell.amount = [self.shoppingCarInfo.orderCount intValue ];
        cell.orderCount.text = [NSString stringWithFormat:@"%d",cell.amount];
    }
    
    if (self.isChangedToSelectMode) {
        cell.backGrayView.hidden = NO;
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
        cell.backGrayView.hidden = NO;
    }
    else{
        ProductDetailViewController *detail = [[ProductDetailViewController alloc]init];
        self.shoppingCarInfo = [self.shoppingCarArray objectAtIndex:indexPath.section];
        detail.foodId = self.shoppingCarInfo.foodId;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)requestForDelete:(NSString *)orderId
{
    NSString *url = [NSString stringWithFormat:@"%@%@",kServerAddress,kEditShoppingCarUrl];
    NSMutableDictionary *dict = kCommonParamsDict;
    [dict setObject:kCampusId forKey:@"campusId"];
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
    [[YFProgressHUD sharedProgressHUD] showActivityViewWithMessage:@"加载中..."];
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
            [[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
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
//            if([self.shoppingCarArray count] == 0)
//            {
//                [self loadSubViews];
//            }
//            else
//            {
//                [self.ShoppingCarTableView removeFooter];
//                self.ShoppingCarTableView.scrollEnabled = YES;
//                self.CalculateView.hidden = NO;
            //}
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
