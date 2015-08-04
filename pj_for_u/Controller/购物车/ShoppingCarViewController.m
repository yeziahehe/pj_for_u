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

#define kGetShoppingCarDownloaderKey    @"GetShoppingCarDownloaderKey"
#define kEditShoppingCarDownloaderKey   @"EditShoppingCarDownloaderKey"
@interface ShoppingCarViewController ()
@property (strong, nonatomic) IBOutlet UITableView *ShoppingCarTableView;
@property (strong, nonatomic) ShoppingCar *shoppingCarInfo;
@property (strong, nonatomic) NSMutableArray *shoppingCarArray;
@property (strong, nonatomic) IBOutlet UIView *noOrderView;
@property (strong, nonatomic) IBOutlet UIView *CalculateView;
@property (strong, nonatomic) IBOutlet UIButton *goAroundButton;

@end
@implementation ShoppingCarViewController

- (void)loadSubViews
{
    //初始化界面为购物车中没有商品
    CGRect rect = self.noOrderView.frame;
    rect.size.height = ScreenHeight;
    rect.size.width = ScreenWidth;
    self.noOrderView.frame = rect;
    self.shoppingCarArray = [NSMutableArray arrayWithCapacity:0];
    self.ShoppingCarTableView.tableFooterView = self.noOrderView;
    self.ShoppingCarTableView.scrollEnabled = NO;
    self.CalculateView.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    [[self.goAroundButton layer] setCornerRadius:5];
    [[self.goAroundButton layer] setBorderWidth:0.5];
    [[self.goAroundButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    //[self.ShoppingCarTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[MemberDataManager sharedManager] isLogin]) {
        [self requestForShoppingCar:@"18896554880" page:@"1" limit:@"3"];
    } else {
        [self.ShoppingCarTableView removeHeader];
        [self loadSubViews];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(plusShoppingAmountNotification:) name:kPlusShoppingAmountNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(minusShoppingAmountNotification:) name:kMinusShoppingAmountNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell.discountPrice.text = [NSString stringWithFormat:@"%@",self.shoppingCarInfo.discountPrice];
        cell.originPrice.text = [NSString stringWithFormat:@"原价:%@",self.shoppingCarInfo.price];
        cell.amount = [self.shoppingCarInfo.orderCount intValue ];
        cell.orderCount.text = [NSString stringWithFormat:@"%d",cell.amount];

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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            //[[YFProgressHUD sharedProgressHUD] stoppedNetWorkActivity];
            self.shoppingCarArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *valueArray = [dict objectForKey:@"orderList"];
            for (NSDictionary *valueDict in valueArray) {
                ShoppingCar *shoppingCar = [[ShoppingCar alloc] initWithDict:valueDict];
                [self.shoppingCarArray addObject:shoppingCar];
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
                message = @"获取图片失败";
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

}

- (void)downloader:(YFDownloader *)downloader didFinishWithError:(NSString *)message
{
    NSLog(@"%@",message);
    [[YFProgressHUD sharedProgressHUD] showFailureViewWithMessage:kNetWorkErrorString hideDelay:2.f];
}

@end
